## Skills Reference
- A comprehensive guide to all custom skills lives at `~/.claude/skills-guide.md`. Read it when the user asks about available skills, how to use them, or how they work together. Update it whenever a new skill is added or an existing skill changes.

## Python Environment Management
- On your FIRST Bash command in any session, check if `.conda-env` exists in the project root. If it does, run `conda activate $(cat .conda-env)` before any Python work.
- If `.conda-env` does NOT exist and the project has Python files (`.py`, `requirements.txt`, `pyproject.toml`, etc.), set up the environment:
  1. Create a conda env named after the project directory (hyphens not underscores): `conda create -n <project-name> python=3.11 pip -y`
  2. Write the env name to `.conda-env`
  3. Activate it: `conda activate <project-name>`
- Always use `python -m pip install` (not bare `pip`) as a safety net to ensure packages go into the active env.
- When installing packages, install them into the active conda env — never globally.

## Code Practices
- Always use good code conventions. Ex: use descriptive variable names, modularization, make code readable, and prefer pure functions over side-effectful functions when possible, and write functions with side-effects carefully.
- Whenever you are asked to complete a task follow the explore, plan, code, test, repeat protocol - read the relevant given to you, make a plan to approach the problem, ultrathink ultrathink ultrathink, create tests that only can only be passed by a good solution (don't hard-code solutions to the tests, or modify them to make them pass) implement the solution in code and while implementing verify the reasonableness of solution, and test the solution and repeat the process until you pass the tests
- Always put test files into the tests folder, not in any other folder.