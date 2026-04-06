#!/usr/bin/env python3
"""Remind the user to /compact or /clear when context is growing large.

Runs as a UserPromptSubmit hook. Checks the current session's conversation
file size as a proxy for context length. Warns at thresholds.
"""

import sys
import os
import json
import glob

sys.path = [p for p in sys.path if p not in ("", ".") and os.path.abspath(p) != os.path.abspath(os.getcwd())]


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        return

    cwd = data.get("cwd", os.getcwd())
    session_id = data.get("session_id", "")

    # Find the conversation file for the current session
    encoded_cwd = cwd.replace("/", "-")
    project_dir = os.path.expanduser(f"~/.claude/projects/{encoded_cwd}")

    if not os.path.isdir(project_dir):
        return

    # Find the most recently modified .jsonl file (likely the active conversation)
    jsonl_files = glob.glob(f"{project_dir}/*.jsonl")
    if not jsonl_files:
        return

    latest = max(jsonl_files, key=os.path.getmtime)
    size_mb = os.path.getsize(latest) / (1024 * 1024)

    # Count lines as a rough proxy for turns
    with open(latest, "r") as f:
        line_count = sum(1 for _ in f)

    # Thresholds
    if size_mb > 5 or line_count > 200:
        print(
            "\n⚠️  Context is very large "
            f"({size_mb:.1f}MB, ~{line_count} turns). "
            "Consider /clear (new task) or /compact (keep working).",
            file=sys.stderr,
        )
    elif size_mb > 2 or line_count > 100:
        print(
            f"\n💡 Context growing ({size_mb:.1f}MB, ~{line_count} turns). "
            "/compact soon to keep performance high.",
            file=sys.stderr,
        )


if __name__ == "__main__":
    main()
