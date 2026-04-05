---
name: publish-github-results
description: Build a static GitHub Pages site from experiment results with narrative analysis and deploy it publicly
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, Agent
argument-hint: [experiment description or path] [--narrative "optional narrative guidance"]
---

# Publish Experiment Results to GitHub Pages

You are building a polished, static single-page website from experiment results and deploying it via GitHub Pages. The site should read like a short research blog post — clean, narrative-driven, with plots and analysis.

## Steps

### 1. Locate the experiment results

The user will loosely describe which experiment or folder to use. Find the relevant results by searching for:
- `analysis/` directories containing plots (PNG/SVG) and reports (`.md`, `.csv`)
- `experiment.yaml` for experiment metadata (W&B entity/project, hyperparams, train command)
- W&B dashboard links in report files
- Training scripts for setup details (model architecture, dataset, etc.)

If multiple experiments exist and it's ambiguous, ask the user which one. Do NOT guess.

### 2. Read and understand the results

Read the report, summary table, key findings, and examine plot filenames to understand what each one shows. Read the training script to get accurate details about model architecture, dataset, and hyperparameters. This context is needed to write the narrative.

### 3. Determine where to host

Check if the current repo is public:
```
gh repo view --json visibility --jq '.visibility'
```

- If **public**: use `docs/` in this repo
- If **private**: ask the user — either make this repo public, or create/use a separate public repo for the page. Do NOT change repo visibility without asking.

### 4. Create the site

Create a `docs/` directory (in whichever repo is being used) with:
- `.nojekyll` — empty file to disable Jekyll processing
- `style.css` — clean research blog aesthetic (720px max-width, system fonts, generous whitespace, sticky nav with anchor links, callout boxes, clean tables with horizontal rules only, `<figure>` + `<figcaption>` for plots, responsive media query)
- `plots/` — copy all relevant plot images here (GitHub Pages only serves from the configured directory)
- `index.html` — single-page site with this structure:
  1. **Hero**: title, tagline summarizing the experiment scope, links to W&B dashboard and GitHub repo
  2. **Introduction**: what's being compared and why, motivation for the experiment
  3. **Experimental Setup**: model, dataset, hyperparameter grid, any implementation details worth noting
  4. **Summary Results**: key metrics in a callout box + full results table
  5. **Plot Deep Dives**: one subsection per plot — the image, what it shows, and 2-3 paragraphs of analysis
  6. **Notable Findings**: any anomalies or surprising results worth highlighting
  7. **Conclusions**: nuanced takeaways, limitations, future directions
  8. **Footer**: links to repo, W&B, attribution

If the user provided narrative guidance, weave that perspective throughout the analysis sections. Otherwise, construct a balanced narrative from the data.

Do NOT use JavaScript. Pure HTML + CSS only.
Do NOT modify any existing experiment files, scripts, or results.
Do NOT use CSS frameworks — write minimal custom CSS.

### 5. Deploy via GitHub Pages

```bash
# Enable GitHub Pages
gh api repos/OWNER/REPO/pages --method POST --input - <<'EOF'
{"source":{"branch":"main","path":"/docs"}}
EOF
```

If Pages is already enabled, this step will error — that's fine, it means it's already set up.

Commit and push the `docs/` folder:
```bash
git add docs/
git commit -m "Add GitHub Pages site for [experiment name] results"
git push origin main
```

### 6. Verify

Wait 10 seconds, then check the deployment:
```bash
gh api repos/OWNER/REPO/pages --jq '.html_url'
```

Print the live URL. Then fetch the page and verify it returns a 200 and contains expected content (plot image references, section headings):
```bash
curl -s -o /dev/null -w "%{http_code}" <URL>
```

If the page returns 404, it may still be building — tell the user to wait a minute and try again.

Print the final URL prominently so the user can share it.

## Verification
- The GitHub Pages URL returns HTTP 200
- The HTML contains `<img>` tags for all plots
- The page has all narrative sections (introduction through conclusions)
- Print: `Site live at: <URL>`
