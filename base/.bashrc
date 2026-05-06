# .bashrc

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    if [ -r /home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh ]; then
        . /home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh
    fi
fi

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

if [ -x "$HOME/work/scripts/dev" ]; then
    alias dev="$HOME/work/scripts/dev"
fi

if [ -x "$HOME/work/scripts/doccle-local" ]; then
    alias doccle-local="$HOME/work/scripts/doccle-local"
    alias doccle-local-kill="$HOME/work/scripts/doccle-local kill"
    alias doccle-local-reset="$HOME/work/scripts/doccle-local reset"
fi

eval "$(starship init bash)"
eval "$(zoxide init bash)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
