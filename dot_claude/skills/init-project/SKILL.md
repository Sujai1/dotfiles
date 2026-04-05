---
name: init-project
description: Initialize a new project with git repo, GitHub remote, .gitignore, experiment.yaml template, and auto-commit infrastructure. Use when starting a new experiment project from scratch.
allowed-tools: Bash, Read, Write, Edit
argument-hint: [project-name] [--public]
---

# Init Project Skill

You are helping the user initialize a new experiment project with git, GitHub, and the experiment infrastructure.

## Arguments
- `$ARGUMENTS[0]` — project name (e.g. `reward-shaping-v2`). If not provided, ask the user.
- `$ARGUMENTS[1]` — optional `--public` flag (default: private repo)

## Step 1 — Verify prerequisites

```bash
# Check git
git --version

# Check GitHub CLI
gh auth status

# Check we're in a directory that makes sense
pwd
```

If `gh auth status` fails, tell the user to run `gh auth login`.

## Step 2 — Initialize git

If already a git repo, skip this step and tell the user.

```bash
git init
git branch -m main
```

## Step 3 — Create .gitignore

Write a `.gitignore` covering Python, W&B, experiment outputs, secrets, and OS files:

```
# Python
__pycache__/
*.pyc
*.pyo
*.egg-info/
dist/
build/

# W&B
wandb/
wandb_local_runs/

# Experiment outputs
outputs/
results/
analysis/*/histories/

# EC2
ec2/.instances

# Environment
.env
*.pem

# OS
.DS_Store

# IDE
.vscode/
.idea/
```

If a `.gitignore` already exists, merge rather than overwrite — add any missing entries.

## Step 4 — Create conda environment

Create a dedicated conda env for the project and drop a `.conda-env` file so the auto-activate hook picks it up:

```bash
# Use the project name as the env name (with hyphens, not underscores)
ENV_NAME="<project-name>"   # e.g. reward-shaping-v2

# Create env with Python 3.11 (stable for ML work)
conda create -n "$ENV_NAME" python=3.11 -y

# Write the marker file for auto-activation
echo "$ENV_NAME" > .conda-env

# Activate it for the rest of setup
conda activate "$ENV_NAME"
```

If a `.conda-env` file already exists, read it and activate that env instead of creating a new one.

Add `.conda-env` to `.gitignore` is NOT needed — it should be committed so collaborators know which env to use.

## Step 5 — Copy experiment template

If `experiment.yaml` doesn't exist and `experiment.template.yaml` is available (in `~/Desktop/shreshth_play/`), copy it:

```bash
cp ~/Desktop/shreshth_play/experiment.template.yaml ./experiment.yaml
```

Tell the user to edit it for their project.

## Step 6 — Copy EC2 scripts and auto-commit script

If the `ec2/` directory doesn't exist, copy the infrastructure:

```bash
cp -r ~/Desktop/shreshth_play/ec2 ./ec2/
chmod +x ec2/*.sh
```

This brings in `launch.sh`, `stop.sh`, `config.sh`, `setup-aws.sh`, and `pre-experiment-commit.sh`.

## Step 7 — Initial commit

```bash
git add -A
git commit -m "Initial project setup: <project-name>

Experiment infrastructure with EC2 automation, auto-commit hooks,
and experiment.yaml template."
```

## Step 8 — Create GitHub repo and push

```bash
# Default to private
gh repo create <project-name> --private --source=. --push --description "<description>"

# If --public flag was passed:
gh repo create <project-name> --public --source=. --push --description "<description>"
```

Ask the user for a one-line description if they didn't provide one.

## Step 9 — Summary

```
══════════════════════════════════════════════
  Project Initialized: <project-name>
  Git:    main branch, initial commit
  GitHub: https://github.com/<user>/<project-name>
  
  Next steps:
  1. Edit experiment.yaml (train_command, wandb_project, requirements)
  2. /prepare-env — build AMI with dependencies
  3. /run-experiment test-1 — quick sanity check
  4. /run-sweep sweep-v1 — full hyperparameter search
  5. /analyze-sweep sweep-v1 — pull results and generate report
══════════════════════════════════════════════
```

## Notes
- Default repo visibility is **private**
- The auto-commit script (`ec2/pre-experiment-commit.sh`) is included so experiments always have a clean code snapshot
- If the user already has a git repo but no GitHub remote, skip to Step 7
- If the user already has both git and GitHub, just verify the setup and report status
