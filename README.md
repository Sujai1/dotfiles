# Dotfiles

Portable dev environment: zsh, tmux, kitty, neovim (LazyVim), Claude Code, sesh, aerospace.

## Bootstrap a new Mac

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Install chezmoi + ansible
brew install chezmoi ansible

# 3. Pull this repo and apply configs
chezmoi init --apply Sujai1

# 4. Install all software
ansible-playbook ~/.local/share/chezmoi/ansible/setup.yml

# 5. Create your secrets file (API keys)
cat > ~/.secrets << 'EOF'
export ANTHROPIC_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
export GROQ_API_KEY="your-key-here"
export TOGETHER_API_KEY="your-key-here"
export THINKING_MACHINES_API_KEY="your-key-here"
export HF_TOKEN="your-token-here"
EOF
chmod 600 ~/.secrets

# 6. Authenticate GitHub CLI
gh auth login

# 7. Open kitty — tmux and Claude Code auto-launch
```

## What's managed

| Tool | Config files |
|------|-------------|
| zsh | `.zshrc`, `.zprofile` |
| tmux | `.tmux.conf` |
| kitty | `.config/kitty/kitty.conf` |
| neovim | `.config/nvim/` (LazyVim) |
| sesh | `.config/sesh/sesh.toml` |
| Claude Code | `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/scripts/`, `.claude/skills/` |
| Custom scripts | `.local/bin/claude-edit`, `.local/bin/claude-fork` |

## Updating

```bash
# After changing a config file, re-add it to chezmoi:
chezmoi add ~/.tmux.conf

# Or edit directly in the chezmoi source:
chezmoi edit ~/.tmux.conf

# Push changes:
chezmoi cd && git add -A && git commit -m "update" && git push

# Pull on another machine:
chezmoi update
```

## Secrets

API keys live in `~/.secrets` (never committed). Copy manually between machines.
