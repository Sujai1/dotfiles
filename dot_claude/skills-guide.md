# Skills Guide

A living reference for all custom Claude Code skills — what they do, how they compose, and what's needed before using them.

---

## Prerequisites (one-time setup)

These must be done once before any experiment skills work:

1. **AWS CLI configured** — `aws sts get-caller-identity` should return your account
2. **EC2 key pair** — PEM file at `~/Desktop/Sujai.pem`, key pair named `Sujai` in AWS (us-east-2)
3. **Security group created** — run `~/Desktop/shreshth_play/ec2/setup-aws.sh` once to create `rl-training-sg` and S3 bucket
4. **W&B account** — logged in via `wandb login`, API key stored in `~/.netrc`
   - Entity: `hiremath-sujai1`
   - Dashboard: https://wandb.ai/hiremath-sujai1/

---

## Skill Overview

### `/init-project [project-name] [--public]`
**Purpose:** Initialize a new experiment project with git, GitHub, .gitignore, experiment template, and auto-commit infrastructure.
**What it does:**
1. Initializes git repo on `main` branch
2. Creates `.gitignore` for Python, W&B, outputs, secrets
3. Copies `experiment.template.yaml` and `ec2/` scripts into the project
4. Makes an initial commit
5. Creates a GitHub repo (private by default) and pushes

**When to use:** Starting any new experiment project from scratch.
**Depends on:** `gh auth login` must have been run. AWS setup optional (only needed for experiment skills).
**Location:** `~/.claude/skills/init-project/SKILL.md`

### `/new-experiment [name] [instance-type]`
**Purpose:** Spin up a single EC2 GPU spot instance for ad-hoc work.
**What it does:** Launches from latest AWS DLAMI, configures SSH, syncs code. Bare-metal — no pre-installed deps.
**When to use:** Quick one-off instance when you want full manual control.
**Location:** `~/.claude/skills/new-experiment/SKILL.md`

### `/prepare-env [experiment-yaml-path]`
**Purpose:** Build a reusable AMI with all project dependencies pre-installed.
**What it does:**
1. Reads `experiment.yaml` → `env` section
2. Launches a temporary EC2 instance (via `launch.sh`)
3. Installs pip requirements, W&B, and any custom setup
4. Saves the instance as a custom AMI
5. Writes the AMI ID back to `experiment.yaml` → `env.snapshot_ami`
6. Terminates the temporary instance

**When to use:** Once per project, or whenever dependencies change.
**Depends on:** `experiment.yaml` must exist in the project. AWS + W&B must be configured.
**Location:** `~/.claude/skills/prepare-env/SKILL.md`

### `/run-experiment [name] [extra-args...]`
**Purpose:** Run a single training experiment on EC2.
**What it does:**
0. Auto-commits code via `ec2/pre-experiment-commit.sh` (ensures reproducibility)
1. Reads `experiment.yaml` → `experiment` section
2. Launches EC2 from the prepared AMI (`env.snapshot_ami`)
3. Syncs project code to the instance
4. Runs the training command (with optional extra args)
5. Logs metrics to W&B
6. Pulls results and shows inline plots (if iTerm2 + imgcat available)
7. Asks whether to keep or terminate the instance

**When to use:** Quick sanity-check runs before committing to a full sweep.
**Depends on:** `/prepare-env` must have been run first (needs `snapshot_ami`).
**Location:** `~/.claude/skills/run-experiment/SKILL.md`

### `/run-sweep [sweep-name] [experiment-yaml-path]`
**Purpose:** Run a hyperparameter sweep across multiple EC2 instances.
**What it does:**
0. Auto-commits code via `ec2/pre-experiment-commit.sh` (ensures reproducibility)
1. Reads `experiment.yaml` → `sweep` section
2. Generates the full grid of hyperparameter combinations
3. Plans scheduling:
   - **Wide mode** (trials <= max_parallel_instances): 1 instance per trial
   - **Deep mode** (trials > max_parallel_instances): multiple trials per instance, sequential
4. Launches instances from prepared AMI
5. Distributes and runs trials, all logging to W&B with a shared group name
6. Monitors progress via W&B API
7. Provides ranked results table + analysis in terminal
8. Terminates all instances

**When to use:** When you want to systematically explore hyperparameters.
**Depends on:** `/prepare-env` must have been run first.
**Location:** `~/.claude/skills/run-sweep/SKILL.md`

### `/analyze-sweep [sweep-name] [experiment-yaml-path]`
**Purpose:** Pull experiment results from W&B, store locally, and produce analysis with plots, tables, and key findings.
**What it does:**
1. Reads `experiment.yaml` for W&B entity/project
2. Pulls all runs for the sweep group from W&B API (configs, summaries, per-epoch histories)
3. Stores raw data locally as CSV + JSON in `analysis/<sweep_name>/`
4. Auto-detects swept hyperparameters and primary metric
5. Generates plots: metric box plot, loss curves, convergence, runtime, head-to-head
6. Prints summary table and narrative analysis in terminal
7. Saves a markdown report

**When to use:** After `/run-sweep` finishes and instances are terminated. All data lives in W&B at that point.
**Depends on:** W&B must have runs for the given sweep group. `experiment.yaml` needed for entity/project.
**Location:** `~/.claude/skills/analyze-sweep/SKILL.md`

### `/browse-s3 [query]`
**Purpose:** Browse, search, and summarize experiment artifacts (checkpoints, datasets, logs) stored in S3.
**What it does:**
1. Lists experiments in S3 with sizes, file counts, and dates
2. Filters by name, date range, or keywords
3. Shows detailed breakdown of a single experiment's contents
4. Provides storage cost estimates and cleanup suggestions
5. Cross-references with W&B to connect checkpoints to training runs
6. Handles deletion with confirmation

**Queries:** `list`, `recent`, `summary <name>`, `size`, `cleanup`, or any search term
**When to use:** When you want to know what artifacts are available from past experiments, check storage costs, or clean up old data.
**Depends on:** AWS CLI configured. No EC2 needed — runs locally.
**Location:** `~/.claude/skills/browse-s3/SKILL.md`

### `/publish-github-results [experiment description or path]`
**Purpose:** Build a static GitHub Pages site from experiment results with narrative analysis and deploy it publicly.
**What it does:**
1. Locates experiment results (plots, reports, configs) from user description
2. Reads training scripts and reports to understand the full context
3. Determines hosting — uses current repo if public, asks user otherwise
4. Creates a `docs/` directory with a polished single-page HTML site (research blog aesthetic, plots with narrative deep dives, summary table, conclusions)
5. Commits, pushes, and enables GitHub Pages
6. Verifies the site is live and prints the shareable URL

**When to use:** When you want to share experiment results as a public webpage. Say "spin out a github page" or "publish results to a website."
**Depends on:** `gh` CLI authenticated. Experiment results (plots, reports) must exist locally.
**Location:** `~/.claude/skills/publish-github-results/SKILL.md`

### `/fork`
**Purpose:** Fork the current Claude Code session into a new tmux window with full conversation context.
**What it does:**
1. Opens a new tmux window in the same directory
2. Runs `claude --continue --fork-session` in it
3. Original session continues untouched

**When to use:** When you want to explore a different direction, ask questions, or start a parallel task without losing your current session's context.
**Depends on:** Must be running inside tmux.
**Location:** `~/.claude/skills/fork/SKILL.md`

### `/make-skill [skill-name]`
**Purpose:** Create a new Claude Code skill through a structured interview process.
**What it does:**
1. Gets the skill name (from args or by asking)
2. Interviews the user: purpose, anti-goals, verification condition, and relevant extras
3. Generates a SKILL.md file under `~/.claude/skills/<name>/`
4. Updates this skills guide with the new entry
5. Confirms creation

**When to use:** Whenever the user wants to create a new skill.
**Depends on:** Nothing.
**Location:** `~/.claude/skills/make-skill/SKILL.md`

---

## How the skills compose

```
/init-project
  creates git repo + .gitignore
  copies experiment.template.yaml + ec2/ scripts
  creates GitHub repo, pushes initial commit

/run-sweep
  auto-commits code (pre-experiment-commit.sh) → pushes to GitHub
  reads experiment.yaml (sweep section)
  for each trial:
    launches EC2 from snapshot_ami (via launch.sh + CUSTOM_AMI)
    runs training command with trial-specific hyperparams
    logs to W&B with group=<sweep_name>
  summarizes all results

/analyze-sweep
  reads experiment.yaml (experiment section → W&B config)
  pulls all run data from W&B API
  stores locally, generates plots + tables + report

/publish-github-results
  finds experiment results (plots, reports, configs)
  creates docs/ with static HTML site (narrative + plots)
  commits, pushes, enables GitHub Pages
  → public URL at username.github.io/repo-name/

/browse-s3
  queries S3 bucket (rl-experiments-sujai)
  lists/searches/summarizes experiment artifacts
  cross-references with W&B for context
  no EC2 needed — runs locally

/run-experiment
  auto-commits code (pre-experiment-commit.sh) → pushes to GitHub
  reads experiment.yaml (experiment section)
  launches EC2 from snapshot_ami (via launch.sh + CUSTOM_AMI)
  runs training command
  logs to W&B, shows inline results

/prepare-env
  reads experiment.yaml (env section)
  launches temporary EC2 (via launch.sh)
  installs deps, saves AMI
  writes snapshot_ami back to experiment.yaml

/new-experiment
  launches bare EC2 from latest DLAMI (via launch.sh)
  no experiment.yaml needed
```

---

## The experiment.yaml contract

Each project that uses these skills needs an `experiment.yaml` in its root. Copy from the template:

```bash
cp ~/Desktop/shreshth_play/experiment.template.yaml ./experiment.yaml
```

Three sections:
- **`env`** — what gets installed (base AMI, requirements, setup script, snapshot AMI)
- **`experiment`** — how a single run works (train command, instance type, W&B config)
- **`sweep`** — how to run many experiments (hyperparam grid, scheduling, parallelism)

---

## Typical workflow

```bash
# 1. Start a new project
/init-project my-experiment
# → creates git repo, GitHub remote, copies templates + ec2 scripts
# Edit experiment.yaml: set train_command, wandb_project, requirements, hyperparams

# 2. Prepare the environment (once)
/prepare-env
# → installs deps, creates AMI, updates experiment.yaml

# 3. Quick sanity check
/run-experiment test-v1 --lr 1e-3 --epochs 5
# → single run, see results inline

# 4. Full sweep
/run-sweep lr-sweep-v1
# → grid search across instances, results on W&B dashboard

# 5. Analyze results
/analyze-sweep lr-sweep-v1
# → pulls from W&B, generates plots + tables + report locally

# 6. Dependencies change? Re-prepare
/prepare-env
# → rebuilds AMI, updates experiment.yaml

# 7. New hyperparams? Just edit and sweep again
# Edit experiment.yaml sweep section
/run-sweep lr-sweep-v2
/analyze-sweep lr-sweep-v2
```

---

## Key infrastructure files

| File | Purpose |
|------|---------|
| `~/Desktop/shreshth_play/ec2/config.sh` | Shared AWS config (region, key, S3 bucket) |
| `~/Desktop/shreshth_play/ec2/launch.sh` | Launches EC2 instances (supports `CUSTOM_AMI` env var) |
| `~/Desktop/shreshth_play/ec2/stop.sh` | Terminates instances, syncs results to S3 |
| `~/Desktop/shreshth_play/ec2/setup-aws.sh` | One-time AWS setup (security group, S3) |
| `~/Desktop/shreshth_play/ec2/pre-experiment-commit.sh` | Auto-commits + pushes code before experiments |
| `~/Desktop/shreshth_play/experiment.template.yaml` | Template to copy into new projects |

---

## Adding new skills

When adding a new skill to `~/.claude/skills/<name>/SKILL.md`, update this guide with:
1. The skill name and purpose
2. What it does (numbered steps)
3. When to use it
4. What it depends on
5. How it fits into the composition diagram
