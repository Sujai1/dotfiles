---
name: fork
description: Fork the current session into a new tmux window with full conversation context preserved.
allowed-tools: Bash
argument-hint:
---

# Fork Session

Open a new tmux window in the same directory with a forked copy of the current Claude Code session. The original session continues untouched.

## Steps

1. Detect the current working directory.
2. Run the following command to split the current tmux window into a new pane and launch the forked session in it:

```bash
tmux split-window -h -c "$(pwd)" "claude --continue --fork-session"
```

3. Confirm to the user that the fork has been created in an adjacent pane.

## Verification

A new pane should appear side-by-side with the current one, running Claude with the full prior conversation context. Print:
> "Forked into a new pane. Use your tmux pane navigation keys to switch to it."
