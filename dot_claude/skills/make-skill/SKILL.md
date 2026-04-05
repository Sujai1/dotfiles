---
name: make-skill
description: Create a new Claude Code skill through a structured interview. Use when the user wants to create, define, or build a new skill.
allowed-tools: Bash, Read, Write, Edit
argument-hint: [skill-name]
---

# Make Skill

You are helping the user create a new Claude Code skill. Follow this interview process to gather requirements, then generate the skill file.

## Step 1 — Get the skill name

If `$ARGUMENTS[0]` was provided, use it. Otherwise ask:
> "What should this skill be called? (short, hyphenated, e.g. `deploy-staging`)"

## Step 2 — Interview the user

Ask these questions **one at a time**, waiting for each answer before proceeding:

### 2a. Purpose
> "What should `/skill-name` do? Describe the goal in a few sentences."

### 2b. Anti-goals
> "What should `/skill-name` NOT do? Any boundaries or things to explicitly avoid?"

### 2c. Verification
> "How will you know the skill worked? What's the success condition I should check at the end?"

### 2d. Suggested extras
After hearing their answers, suggest any of these that seem relevant and ask if they want to include them:
- **Arguments** — does the skill take any inputs? (e.g. a name, a flag, a file path)
- **Prerequisites** — anything that must be true before the skill runs? (e.g. AWS configured, a file exists)
- **Tools needed** — which tools does the skill need? (default: `Bash, Read, Write, Edit`)
- **Output format** — should results be displayed in a specific way? (e.g. summary box, table)

Only suggest extras that are relevant to what the user described. Keep it brief.

## Step 3 — Generate the skill

Write the SKILL.md file to `~/.claude/skills/<skill-name>/SKILL.md` using this structure:

```markdown
---
name: <skill-name>
description: <one-line description, under 120 chars>
allowed-tools: <comma-separated tool list>
argument-hint: <argument format>
---

# <Skill Title>

<1-2 sentence role instruction>

## Arguments
<list of positional args from $ARGUMENTS>

## Steps
<numbered steps to accomplish the goal — clear, concrete, actionable>
<include anti-goals as explicit "Do NOT..." lines where relevant>

## Verification
<the user's success condition, turned into a concrete check>
<print a clear pass/fail result>
```

**Constraints on the generated skill:**
- Keep the skill under 500 words (excluding frontmatter)
- Steps should be concrete and actionable, not vague
- Weave anti-goals into the steps as "Do NOT..." lines rather than a separate section
- End with the verification step so the user knows it worked

## Step 4 — Update the skills guide

Read `~/.claude/skills-guide.md` and append an entry for the new skill in the "Skill Overview" section, following the existing format:
- Skill name and argument format
- Purpose (one line)
- What it does (numbered list)
- When to use
- Depends on
- Location

Also add it to the composition diagram if it relates to other skills.

## Step 5 — Confirm

Show the user:
> "Created `/skill-name`. Try it out with `/skill-name [args]`."

If anything looks off, offer to edit.
