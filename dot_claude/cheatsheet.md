# Cheat Sheet

Quick reference for all keybindings, commands, and workflows.

---

## Tmux (prefix: Ctrl+A)

| Keys | Action |
|------|--------|
| `Ctrl+A \|` | Split pane horizontally (side by side) |
| `Ctrl+A -` | Split pane vertically (top/bottom) |
| `Ctrl+A c` | New window (same directory) |
| `Ctrl+A x` | Kill current pane |
| `Ctrl+A v` | **Fork Claude Code** session into side pane |
| `Ctrl+A g` | **Claude edit** — context viewer + nvim prompt |
| `Ctrl+A T` | **Sesh** session picker (fzf popup) |
| `Ctrl+A space` | Cycle through pane layouts |
| `Ctrl+A {` / `}` | Swap pane positions |
| `Ctrl+A :` | Tmux command prompt (e.g., `rename-session`) |
| `Ctrl+N` | Split pane below (no prefix) |
| `Ctrl+P` | Split pane right (no prefix) |
| `Ctrl+H/J/K/L` | Navigate panes (vim-style, no prefix) |

### Sesh popup (inside Ctrl+A T)
| Keys | Action |
|------|--------|
| `Ctrl+A` | Show all sessions |
| `Ctrl+T` | Show tmux sessions only |
| `Ctrl+G` | Show config sessions |
| `Ctrl+X` | Show zoxide sessions |
| `Ctrl+F` | Find directories |
| `Ctrl+D` | Kill selected session |

---

## Claude Code

| Keys / Command | Action |
|------|--------|
| `Esc Esc` | Clear current input line |
| `Ctrl+C` | Cancel current response / exit |
| `Ctrl+O` | View full debug/output |
| `/clear` | Clear entire context (fresh start) |
| `/compact` | Summarize context (keep working, save tokens) |
| `/model` | Change model |
| `/effort high` | Standard effort |
| `/effort max` | Maximum effort for big tasks |
| `/voice` | Start voice input |
| `!` | Run a terminal command (Claude sees the output) |
| `Tab` (on "No") | Amend/refine your prompt instead of accepting |

### Aliases (shell)
| Alias | Expands to |
|-------|-----------|
| `ccd` | `claude --dangerously-skip-permissions` |
| `ccdc` | `claude --dangerously-skip-permissions --continue` |
| `rl` | `source ~/.zshrc` (reload shell config) |

### Custom Skills (type in Claude Code)
| Skill | What it does |
|-------|-------------|
| `/fork` | Fork session into new tmux pane |
| `/view-file <file>` | Open file in nvim side pane |
| `/make-skill <name>` | Create a new skill via interview |
| `/init-project <name>` | New project with git + GitHub + templates |
| `/new-experiment <name>` | Spin up EC2 GPU instance |
| `/prepare-env` | Build reusable AMI with deps |
| `/run-experiment <name>` | Single training run on EC2 |
| `/run-sweep <name>` | Hyperparameter sweep across EC2s |
| `/analyze-sweep <name>` | Pull W&B results, generate plots + report |
| `/browse-s3` | Browse experiment artifacts in S3 |
| `/publish-github-results` | Deploy results as GitHub Pages site |

---

## Neovim (LazyVim)

| Keys | Action |
|------|--------|
| `i` | Enter insert mode |
| `Esc` | Exit insert mode |
| `u` | Undo |
| `Ctrl+R` | Redo |
| `q` | Quit (if no changes) |
| `qq` | Force quit (discard changes) |
| `sq` | Save and quit |
| `Esc :wq Enter` | Save and quit (long form) |

---

## Aerospace (tiling WM)

| Keys | Action |
|------|--------|
| `Alt+H/J/K/L` | Focus left/down/up/right |
| `Alt+Shift+H/J/K/L` | Move window left/down/up/right |
| `Alt+1-9` | Switch to workspace 1-9 |
| `Alt+Shift+1-9` | Move window to workspace 1-9 |
| `Alt+Tab` | Toggle last workspace |
| `Alt+/` | Toggle tiles/accordion layout |
| `Alt+Shift+=/-` | Resize window bigger/smaller |
| `Alt+Shift+;` | Enter service mode (then `r`=reset, `f`=float) |

---

## Terminal / Shell

| Command | Action |
|---------|--------|
| `z <term>` | Zoxide — fuzzy cd (learns from usage) |
| `t` | Sesh — fzf session picker |
| `mkdir <name>` | Create directory |
| `cp <src> <dst>` | Copy file |
| `mv <src> <dst>` | Move/rename file |
| `rm <file>` | Delete file |
| `pwd` | Print current directory |
| `nvim <file>` | Open file in neovim |

---

## Kitty

| Keys | Action |
|------|--------|
| `Cmd+T` | New tab (opens in home directory) |

---

## Dotfiles (chezmoi)

| Command | Action |
|---------|--------|
| `chezmoi add <file>` | Track a config file |
| `chezmoi edit <file>` | Edit in chezmoi source |
| `chezmoi apply` | Apply all configs from source |
| `chezmoi update` | Pull + apply from GitHub |
| `chezmoi diff` | See what would change |
| `chezmoi cd` | cd into chezmoi source repo |

### Push config changes
```bash
chezmoi cd && git add -A && git commit -m "update" && git push
```

---

## Work Trial Bootstrap

```bash
# 1. Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 2. Install claude code
brew install node
npm install -g @anthropic-ai/claude-code

# 3. Set API key and launch
export ANTHROPIC_API_KEY="<key-they-give-you>"
claude

# 4. Tell Claude:
# "Set up my dev environment:
#  1. brew install chezmoi ansible age
#  2. chezmoi init --apply Sujai1 (I'll type the passphrase)
#  3. ansible-playbook ~/.local/share/chezmoi/ansible/setup.yml
#  4. In ~/.secrets, replace ANTHROPIC_API_KEY with <their key>
#  5. source ~/.secrets"
```

---

## Key Principles (from Trent & Shreshth)

- **Always challenge initial expectations** about what Claude can accomplish
- **Give it ways to verify** its output, then run in a loop
- **Be incredibly specific** about the constraints of behavior you want
- **Verification is the most important part** of skill design
- **Always /clear** when moving to a new task
- **Use /compact** when context is getting long but you want to keep working
