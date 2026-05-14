# pi extensions

Global pi extensions managed by dotfiles.

Put extension files here, for example:

```text
my-extension.ts
my-extension/index.ts
```

Stow from the dotfiles repo with:

```bash
stow -t $HOME pi
```

Pi auto-discovers these as `~/.pi/agent/extensions/*` and they can be reloaded with `/reload`.
