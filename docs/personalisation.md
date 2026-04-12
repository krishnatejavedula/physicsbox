# Personalisation

## Dotfiles

Store personal shell and editor config in `workspace/dotfiles/` and symlink them so they survive rebuilds:

```bash
mkdir -p /workspace/dotfiles
vim /workspace/dotfiles/.bashrc.local
vim /workspace/dotfiles/.vimrc

ln -s /workspace/dotfiles/.bashrc.local ~/.bashrc.local
ln -s /workspace/dotfiles/.vimrc ~/.vimrc
```

Add to the bottom of `~/.bashrc`:

```bash
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
```

Since `workspace/` is a bind mount on your host, dotfiles survive container rebuilds and image deletions entirely.

---

## Mounting additional folders

To access project folders outside `workspace/` inside the container without editing the shared `docker-compose.yml`, use a local override file:

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

Edit with your actual paths:

```yaml
services:
  physicsbox:
    volumes:
      - /path/to/your/project:/workspace/myproject
      - /path/to/another:/workspace/another
```

Then restart:

```bash
make restart
```

`docker-compose.override.yml` is gitignored — it stays on your machine and is never committed to the repo.
