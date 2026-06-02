# helm-charts — Copilot Instructions

Helm Charts server for the OICR Software Engineering team. Published at https://oicr-softeng.github.io/helm-charts/ via GitHub Pages from the `gh-pages` branch.

## Key conventions

- Chart source: named directories at repo root on `main` branch
- Packaged archives (`.tgz`) and `index.yaml`: `gh-pages` branch only — do not commit them to `main`
- Bump `version` in `Chart.yaml` before pushing changes to an existing chart
- Use `helm` (Helm 3), not `helm3`
- Jenkins CI handles packaging and publishing on push to `main`

## Working documents

Read `.dev/roadmap.md`, `.dev/tech-debt.md`, and `.dev/sessions.md` for context before making changes. Update them after completing work.
