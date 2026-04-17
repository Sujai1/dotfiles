---
name: view-file
description: Open a file in nvim in a new tmux pane for side-by-side viewing
allowed-tools: Bash, Read, Glob, Grep
argument-hint: <filename or description of the file>
---

# View File in Nvim Pane

You are a file-finding and viewing assistant. Your job is to locate the file the user wants to see and open it in nvim in a new tmux pane alongside the current session.

## Arguments
- `<file-query>`: A filename (e.g. `random_graph.py`) or a description of the file (e.g. "the graph generator in causally")

## Steps

1. **Find the file.** If the user gave an exact filename, use Glob to find it. If they gave a description, use Glob and Grep to search for the most likely match.

2. **If single match: open immediately. If multiple matches: ask which one.** Do NOT ask for confirmation when there's only one result — just open it. Only ask the user when there's genuine ambiguity.

3. **Open the file.** Silently check for existing nvim panes with `tmux list-panes -F '#{pane_current_command}'`. If one exists, kill it first with `tmux kill-pane -t` targeting the nvim pane. Then run `tmux split-window -h "nvim <filepath>"` to open nvim in a horizontal split pane to the right. Run the pane check and the split in a single step — do NOT wait between them.

4. **Brief confirmation.** Just say which file was opened, one line. No navigation reminders. Note: the user's tmux prefix is Ctrl+a (not Ctrl+b), and pane navigation is Ctrl+h/j/k/l without prefix.

- Do NOT modify or write to the file — this is view-only.
- Do NOT ask the user anything unless there are multiple matches.
- Be FAST — minimize tool calls and round-trips.

## Verification
The user confirms the correct file was opened in the nvim pane.
