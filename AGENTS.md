# helm-charts — AGENTS.md

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
├── Makefile       # Local dev helpers and gh-pages bootstrap utility
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

Before starting work, read:
1. `.dev/roadmap.md` — current focus and planned work
2. `.dev/tech-debt.md` — known issues (prioritise `standalone: yes` entries)
3. `.dev/sessions.md` — last 1–2 entries for recent context

After completing a meaningful unit of work, update the relevant `.dev/` documents and add a dated entry to `.dev/sessions.md` (**Done** / **Decisions** / **Open threads**). Do not log conversational activity — code changes, decisions, and open threads only.
