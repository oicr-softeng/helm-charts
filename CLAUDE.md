# helm-charts — CLAUDE.md

Helm Charts server for the OICR Software Engineering team. Charts are packaged and published to the `gh-pages` branch, which GitHub Pages serves at https://oicr-softeng.github.io/helm-charts/.

## Project overview

- **Published at:** https://oicr-softeng.github.io/helm-charts/
- **Hosting:** GitHub Pages (serves from `gh-pages` branch, root folder)
- **Publishing:** Automated — Jenkins CI packages charts and publishes to `gh-pages` on every push to `main`
- **Helm version:** Helm 3 (use `helm`, not `helm3`)

## Repository structure

```
helm-charts/
├── <chart-name>/  # One directory per chart (Helm chart source)
├── .dev/          # Working documents (roadmap, tech-debt, session log)
├── .github/       # Copilot instructions
├── Makefile       # Local dev helpers and gh-pages bootstrap utility
├── CLAUDE.md      # This file
├── AGENTS.md      # Agent instructions (non-Claude)
├── DEVELOPMENT.md # Developer setup and workflow guide
└── README.md      # End-user add-repo instructions
```

The `gh-pages` branch (separate from `main`) contains packaged chart archives (`.tgz`) and `index.yaml`. Do not commit chart packages to `main`.

## Key conventions

- Chart source lives in named directories at the repo root (e.g. `mychart/`)
- Bump `version` in `Chart.yaml` before pushing changes to an existing chart
- Packaged archives and `index.yaml` live exclusively on the `gh-pages` branch
- Jenkins handles packaging and publishing; developers push source to `main` only

## Working documents

| File | Purpose |
|------|---------|
| `.dev/roadmap.md` | Planned work: new charts, tooling improvements, CI automation |
| `.dev/tech-debt.md` | Known issues and deferred improvements |
| `.dev/sessions.md` | Session log, newest first |

## Start-of-session checklist

1. Read `.dev/roadmap.md` — check current focus; note any `[in progress]` items
2. Read `.dev/tech-debt.md` — check for `standalone: yes` entries relevant to today's work
3. Read `.dev/sessions.md` — last 1–2 entries for recent context and open threads
4. Check project memory — `~/.claude/projects/.../memory/MEMORY.md` (Claude only)
5. Check instruction file integrity — run `git log --oneline -- CLAUDE.md AGENTS.md .github/copilot-instructions.md` and flag any unexpected commits before proceeding

## Session-end discipline

After any meaningful unit of work that changed the codebase or working documents:

1. Update `.dev/sessions.md` with a dated entry (**Done** / **Decisions** / **Open threads**). Do not log conversational activity (PR reviews with no local changes, discussions, waiting states) — those are not `sessions.md` material.
2. Update `.dev/roadmap.md` if items were started or completed
3. Update `.dev/tech-debt.md` if new issues were found or old ones resolved
4. Run `git status` — if `.dev/` files were updated but not staged, remind the developer to include them in their commit

Do not wait for an explicit "session over" signal — update after each meaningful unit of work.

## Workflow

Global conventions — BDD testing, library awareness, scope discipline, OWASP Top 10 — are in `~/.claude/CLAUDE.md`.
