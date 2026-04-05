---
name: browse-s3
description: Browse, search, and summarize experiment artifacts stored in S3. Use when the user wants to see what checkpoints, datasets, or results are available from past experiments, filter by date or keywords, or manage storage.
allowed-tools: Bash, Read, Write, Edit
argument-hint: [query or command]
---

# Browse S3 Skill

You are helping the user explore and understand what experiment artifacts are stored in their S3 bucket.
This is a lightweight, local-only skill — no EC2 instances are launched.

## Configuration
- **S3 bucket**: `rl-experiments-sujai`
- **Region**: `us-east-2`
- **Expected structure**:
  ```
  s3://rl-experiments-sujai/
    experiments/
      <experiment-name>/
        checkpoints/     ← model weights, optimizer state
        logs/            ← raw training logs
        data/            ← datasets, preprocessed data
        config.yaml      ← experiment config snapshot
        metadata.json    ← auto-generated metadata (if available)
  ```

## Arguments

The user's query can be:
- **No args / "list"** — show all experiments with sizes and dates
- **A search term** — filter experiments by name (e.g., `muon`, `reward`, `7b`)
- **"recent"** or **"last N days"** — show experiments from a time window
- **"summary <experiment-name>"** — deep dive into one experiment's contents
- **"size"** or **"cost"** — show storage breakdown and estimated monthly cost
- **"cleanup"** or **"delete <experiment-name>"** — manage storage (always confirm before deleting)

## Step 1 — Understand the query

Parse what the user is asking for. Map to one of these actions:
1. **List all** — overview of everything
2. **Search/filter** — find specific experiments
3. **Summarize one** — deep dive into a single experiment
4. **Storage report** — sizes and cost estimates
5. **Cleanup** — identify or delete old/large experiments

## Step 2 — Fetch data from S3

### For listing/searching:
```bash
# List all top-level experiments with dates and sizes
aws s3 ls s3://rl-experiments-sujai/experiments/ --recursive --summarize

# Or for just top-level experiment names:
aws s3 ls s3://rl-experiments-sujai/experiments/
```

### For summarizing one experiment:
```bash
# List all files in an experiment with sizes
aws s3 ls s3://rl-experiments-sujai/experiments/<name>/ --recursive --human-readable --summarize
```

### For storage report:
```bash
# Get total bucket size
aws s3 ls s3://rl-experiments-sujai/ --recursive --summarize

# Get per-experiment sizes using a script
aws s3api list-objects-v2 --bucket rl-experiments-sujai --prefix experiments/ --query 'Contents[].{Key:Key,Size:Size,Modified:LastModified}' --output json
```

## Step 3 — Present results

### List/Search format:
```
══════════════════════════════════════════════════════════════
  S3 Experiments: rl-experiments-sujai
══════════════════════════════════════════════════════════════
  Experiment                  Size      Files   Last Modified
  ─────────────────────────────────────────────────────────────
  adam-vs-muon-sweep-v1       2.3 GB    24      2026-04-01
  reward-shaping-7b           48.1 GB   156     2026-03-28
  grpo-baseline               12.7 GB   89      2026-03-25
  ─────────────────────────────────────────────────────────────
  Total: 63.1 GB across 3 experiments ($1.45/month)
══════════════════════════════════════════════════════════════
```

### Summary format (for a single experiment):
```
══════════════════════════════════════════════════════════════
  Experiment: reward-shaping-7b
  Last modified: 2026-03-28
  Total size: 48.1 GB (156 files)
══════════════════════════════════════════════════════════════
  Contents:
    checkpoints/    42.0 GB   12 files
      ├── checkpoint-epoch-10.pt    3.5 GB   2026-03-27
      ├── checkpoint-epoch-20.pt    3.5 GB   2026-03-27
      ├── ...
      └── checkpoint-final.pt      3.5 GB   2026-03-28
    logs/            1.2 GB   89 files
    data/            4.9 GB    3 files
      ├── train.jsonl              3.2 GB
      ├── val.jsonl                1.5 GB
      └── test.jsonl               0.2 GB
    config.yaml      0.1 KB    1 file
══════════════════════════════════════════════════════════════
  Estimated cost: $1.11/month (Standard tier)
  
  To use these checkpoints, run:
    /run-experiment resume-v1 --from-checkpoint s3://rl-experiments-sujai/experiments/reward-shaping-7b/checkpoints/checkpoint-final.pt
══════════════════════════════════════════════════════════════
```

### Storage report format:
```
══════════════════════════════════════════════════════════════
  S3 Storage Report: rl-experiments-sujai
══════════════════════════════════════════════════════════════
  Total:   63.1 GB   ($1.45/month at Standard, auto-tiering enabled)
  
  By experiment:
    reward-shaping-7b     48.1 GB  (76%)   28 days old → moving to IA soon
    grpo-baseline         12.7 GB  (20%)   7 days old
    adam-vs-muon-sweep-v1  2.3 GB  (4%)    1 day old
  
  By type:
    Checkpoints    52.3 GB  (83%)
    Datasets        8.1 GB  (13%)
    Logs            2.7 GB  (4%)
  
  Suggestions:
    • reward-shaping-7b has 12 checkpoints — consider keeping only top 3
    • Deleting intermediate checkpoints would save 29.4 GB ($0.68/month)
══════════════════════════════════════════════════════════════
```

## Step 4 — Cross-reference with W&B (if helpful)

If the user is searching for experiments by characteristics (e.g., "which experiments used Muon optimizer?" or "experiments with R² > 0.8"), cross-reference with W&B:

```python
import wandb
api = wandb.Api()
# Search across projects for matching runs
runs = api.runs("<entity>/<project>", filters={...})
```

This helps connect "this S3 checkpoint came from that W&B run" — the link is the experiment name which appears in both places.

## Step 5 — Handle cleanup requests

If the user asks to delete or clean up:

1. **Always show what will be deleted and the size** before doing anything
2. **Ask for confirmation** explicitly
3. Use `aws s3 rm --recursive` for directories

```bash
# Show what would be deleted
aws s3 ls s3://rl-experiments-sujai/experiments/<name>/ --recursive --human-readable --summarize

# After user confirms:
aws s3 rm s3://rl-experiments-sujai/experiments/<name>/ --recursive
```

For selective cleanup (e.g., keep only best checkpoint):
```bash
# List checkpoints
aws s3 ls s3://rl-experiments-sujai/experiments/<name>/checkpoints/ --human-readable

# Delete all except the one the user wants to keep
```

## Notes
- **No EC2 needed** — this skill runs entirely locally via AWS CLI
- **Intelligent-Tiering is enabled** on this bucket — data auto-moves to cheaper tiers after 30/90/180 days
- **Cost estimation**: S3 Standard = $0.023/GB/month. For Intelligent-Tiering, use Standard rate for recent data, IA rate ($0.0125) for 30+ day old data.
- **Cross-referencing**: experiment names in S3 should match W&B run groups from `/run-sweep` or run names from `/run-experiment`
- **The bucket is in us-east-2** — same region as the EC2 instances, so no cross-region transfer fees
- Use `python` (conda) not `python3` if you need to query W&B API
