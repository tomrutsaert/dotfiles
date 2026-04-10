# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# history
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=
HISTTIMEFORMAT="[%F %T] "

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias home='cd ~'

# File Operations
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Use Vim instead of Vi
alias vi='nvim'
alias vim='nvim'

export EDITOR=nvim

alias ollama='docker exec -it ollama ollama'

unset rc

if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Doccle specific
if [ -f "$HOME/secrets/doccle/setenv" ]; then
    source "$HOME/secrets/doccle/setenv"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(starship init bash)"
eval "$(zoxide init bash)"

dev() {
    local project="$1"
    local worktree="$2"
    if [ -z "$project" ]; then
        echo "Usage: dev <project> [worktree]"
        return 1
    fi

    local projects_file="$HOME/projects/doccle/doccle-dev-containers/projects.yaml"
    local dev_containers_dir="$HOME/projects/doccle/doccle-dev-containers"

    # Parse directory from projects.yaml
    local project_dir
    project_dir=$(awk -v proj="$project" '
        $0 ~ "^  " proj ":" { found=1; next }
        found && /directory:/ { gsub(/^ *directory: */, ""); print; exit }
        found && /^  [a-z]/ { exit }
    ' "$projects_file")

    if [ -z "$project_dir" ]; then
        echo "Project '$project' not found in $projects_file"
        return 1
    fi

    # Expand ~ to $HOME
    project_dir="${project_dir/#\~/$HOME}"

    local session="$project"
    local wt_arg=""
    if [ -n "$worktree" ]; then
        session="$project-$worktree"
        wt_arg="wt=$worktree"
        # Create worktree via make run (this creates the worktree directory)
        local worktree_dir="${project_dir}-${worktree}"
        if [ ! -d "$worktree_dir" ]; then
            echo "Creating worktree '$worktree' for $project..."
            make -C "$dev_containers_dir" run "$project" "$wt_arg"
        fi
        project_dir="$worktree_dir"
    fi

    # Open IntelliJ in the background
    idea "$project_dir" &>/dev/null &

    if tmux has-session -t "$session" 2>/dev/null; then
        tmux attach-session -t "$session"
        return
    fi

    # Window 1: lazygit
    tmux new-session -d -s "$session" -c "$project_dir" -n "git"
    tmux send-keys -t "$session:git" "lazygit" Enter

    # Window 2: make install (if available)
    tmux new-window -t "$session" -c "$project_dir" -n "install"
    if [ -f "$project_dir/Makefile" ] && grep -q '^install:' "$project_dir/Makefile"; then
        tmux send-keys -t "$session:install" "make install" Enter
    fi

    # Start the dev container before claude/codex to avoid race condition
    make -C "$dev_containers_dir" run "$project" $wt_arg
    sleep 0.5

    # Window 3: make claude
    tmux new-window -t "$session" -c "$dev_containers_dir" -n "claude"
    tmux send-keys -t "$session:claude" "make claude $project $wt_arg" Enter

    # Window 4: make codex
    tmux new-window -t "$session" -c "$dev_containers_dir" -n "codex"
    tmux send-keys -t "$session:codex" "make codex $project $wt_arg" Enter

    # Attach to session
    tmux select-window -t "$session:claude"
    tmux attach-session -t "$session"
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
