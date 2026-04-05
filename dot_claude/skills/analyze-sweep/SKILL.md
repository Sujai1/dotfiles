---
name: analyze-sweep
description: Pull experiment results from W&B, store locally, and produce analysis (plots, tables, key findings). Run this after /run-sweep finishes and instances are terminated.
allowed-tools: Bash, Read, Write, Edit
argument-hint: [sweep-name] [experiment-yaml-path]
---

# Analyze Sweep Skill

You are helping the user pull experiment results from Weights & Biases, store them locally,
and produce a thorough analysis with plots, tables, and key findings — all displayed in the terminal.

**Run this after** `/run-sweep` completes and instances are terminated. All data lives in W&B at that point.

## Configuration
- **W&B entity**: read from `experiment.yaml` → `experiment.wandb_entity`
- **W&B project**: read from `experiment.yaml` → `experiment.wandb_project`
- **Local Python**: use `python` (conda) not `python3` (system) — the conda env has wandb installed
- **Output dir**: `<project_root>/analysis/<sweep_name>/`

## Arguments
- `$ARGUMENTS[0]` — sweep name (the W&B group name used by `/run-sweep`). If not provided, ask the user.
- `$ARGUMENTS[1]` — path to experiment.yaml (default: `./experiment.yaml`)

## Step 1 — Read experiment.yaml and connect to W&B

Read experiment.yaml to get `wandb_entity` and `wandb_project`.

Verify W&B API access:
```python
import wandb
api = wandb.Api()
runs = list(api.runs("<entity>/<project>", filters={"group": "<sweep_name>"}))
print(f"Found {len(runs)} runs")
```

If no runs are found, tell the user:
> "No runs found for group `<sweep_name>` in `<entity>/<project>`. Check the sweep name or W&B dashboard."

## Step 2 — Pull and store data locally

For each finished run, extract:
- **Config**: parse from `run.config` first. If config is empty, parse from `run.name` (the sweep skill names trials as `trial-N-param1val1-param2val2-...`)
- **Summary metrics**: `run.summary` — all non-underscore keys
- **Per-epoch history**: `run.history(keys=[...], pandas=False)` — all logged metric keys

Store as:
```
analysis/<sweep_name>/
  runs.csv          — one row per run: config + final metrics
  histories/        — one JSON file per run with per-epoch data
    <run_name>.json
```

Write `runs.csv` with columns: `name, <config_cols...>, <metric_cols...>, runtime_s, state`.

Tell the user how many runs were pulled and any that were skipped (failed/crashed).

## Step 3 — Auto-detect metrics and config

Look at the data to understand what was varied and what was measured:

**Config detection**: find columns in runs.csv where values differ across runs. These are the swept hyperparameters.

**Metric detection**: find all numeric columns in run summaries. Identify:
- The **primary metric**: the one most likely to be the "score" — look for keys containing `r2`, `accuracy`, `acc`, `reward`, `score` (prefer these). If none found, use the metric with highest variance across configs.
- **Loss metrics**: keys containing `loss`
- **Other metrics**: everything else

Print what was detected:
> "Detected sweep over: `optimizer`, `learning_rate`, `seed`"
> "Primary metric: `best_val_r2` (higher is better)"
> "Loss metrics: `train_loss`, `val_loss`"

## Step 4 — Generate summary table

Print a table grouped by the non-seed config dimensions (everything except `seed`):

```
══════════════════════════════════════════════════════════════
  SWEEP: <sweep_name>  |  <N> runs  |  <entity>/<project>
══════════════════════════════════════════════════════════════
  Config               Primary (mean±std)   Loss (final)   Runtime    N
  ─────────────────────────────────────────────────────────────
  <config_1>           0.8062 ± 0.0078      0.2229         82s       10
  <config_2>           0.8060 ± 0.0075      0.2223         79s       10
  ...
  ─────────────────────────────────────────────────────────────
  Best: <config>  (<metric> = <value>)
══════════════════════════════════════════════════════════════
```

Sort by primary metric (descending if r2/acc/score, ascending if loss).

## Step 5 — Generate plots

Create all plots as PNGs in `analysis/<sweep_name>/plots/`. Use matplotlib with `Agg` backend.

### Plot 1: Primary metric box plot
- One box per config group (excluding seed)
- Overlay individual seed points as scatter
- Color-code by the first swept hyperparameter (e.g., optimizer)
- Title: "<Primary Metric> by <Config Dimensions>"

### Plot 2: Training curves (loss)
- For each config group, average train_loss and val_loss across seeds
- Show mean line with std shading
- Subplots: one for train, one for val
- Title: "Loss Curves (mean ± std across seeds)"

### Plot 3: Primary metric over training
- Same as Plot 2 but for the primary metric (e.g., val_r2)
- Single plot with all config groups overlaid

### Plot 4: Runtime comparison
- Bar chart of mean runtime per config group
- Error bars for std
- Only generate if runtime data is available

### Plot 5: Pairwise comparison (if applicable)
- If there are exactly 2 values for one hyperparameter (e.g., optimizer: [adam, muon]),
  create a grouped bar chart comparing them at each level of the other hyperparameters
- This is the "head-to-head" chart

After saving each plot, display it inline using the Read tool (which renders images in Claude Code).

## Step 6 — Key findings and narrative

Analyze the results and print a narrative summary. Cover:

1. **Best configuration** and how much it beats the runner-up
2. **Effect of each hyperparameter**: for each swept param, what's its impact on the primary metric? Use the range of means across levels.
3. **Stability**: which configs have lowest std across seeds? Which have outliers?
4. **Runtime/cost tradeoff**: if one config is slower but only marginally better, note it
5. **Head-to-head comparisons**: at matched settings, which approach wins?
6. **Convergence**: do all configs converge to the same level, or do some plateau earlier/higher?

Format as a clear, numbered list of findings.

## Step 7 — Save analysis report

Write a markdown report to `analysis/<sweep_name>/report.md` containing:
- The summary table
- All findings
- Links to W&B dashboard
- Paths to all generated plots

## Step 8 — Display everything

1. Print the summary table (already done in Step 4)
2. Display each plot inline using the Read tool
3. Print the key findings (already done in Step 6)
4. Print the W&B link: `https://wandb.ai/<entity>/<project>?group=<sweep_name>`
5. Print the local paths: `analysis/<sweep_name>/` for data, plots, and report

## Notes

- **Python binary**: use `python` (conda 3.13) not `python3` (system 3.11) — wandb is installed in conda
- **Config parsing fallback**: W&B config may be empty if the training script used env vars for W&B init. In that case, parse config from run names. The `/run-sweep` skill names trials as `trial-<N>-<key1><val1>-<key2><val2>-...` (e.g., `trial-3-adam-lr0.01-s2`)
- **Metric direction**: auto-detect whether higher is better (r2, accuracy, reward, score) or lower is better (loss, error, mse, mae). Default to higher-is-better.
- **Seed detection**: if a config dimension has ≥8 unique integer values in [0, 100], treat it as a seed (group by other dimensions, aggregate over seeds)
- **Large sweeps**: if >100 runs, fetch histories in batches and show a progress indicator
- **Missing data**: if some runs are failed/crashed, include them in the count but exclude from metric calculations. Report how many were excluded.
- **The `wandb/` directory in the project root**: if it exists, it may shadow the wandb Python package on import. If you get import errors, check for this and rename it (e.g., to `wandb_local_runs/`).
