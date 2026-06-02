# Sessions

## 2026-06-02 —

**Done:**

**Decisions:**

**Open threads:**

---

## 2026-06-01 — Switched to OCI at GHCR; created shared context memories; first chart published

**Done:**

- Switched publishing from `gh-pages` branch to OCI artifacts on GHCR (`oci://ghcr.io/oicr-softeng/helm-charts`) — no index.yaml, no git push in pipeline, simpler overall
- Rewrote `pipelineSoftEngBuildHelmCharts.groovy` iteratively: removed `apk add` (blocked by `runAsUser: 1000`), replaced `yq` with `grep`/`awk`, moved publish stage out of helm container, fixed all `def` warnings, renamed variables to camelCase, removed dead `new_helm_paths`, simplified to 2 stages
- Discovered GitHub Apps cannot push to GHCR (6-year architectural limitation) — reverted pipeline credential to `oicr-sweng-ghcr` PAT; new PAT created with `write:packages` scope
- Added `cron-job` chart (cloned from argo-charts, bumped to 1.2.1): added `concurrencyPolicy: Forbid`, `successfulJobsHistoryLimit`, `failedJobsHistoryLimit`; removed dead `service.internalPort`; fixed template spacing; alphabetized values
- Removed `.dev/Makefile` (irrelevant after OCI switch)
- Updated `README.md` and `DEVELOPMENT.md` for OCI usage; added note about GitHub's misleading Docker pull command on the package page
- Logged tech debt: `imagePullSecrets` type fix, missing chart `icon`
- Pipeline tested end-to-end: `cron-job-1.2.1` successfully published to GHCR

**Decisions:**

- OCI over gh-pages: simpler pipeline, no shared index to corrupt, atomic per-chart pushes, better long-term direction
- GitHub Apps cannot authenticate with GHCR — PAT required; `oicr-sweng-ghcr` is the credential
- `grep`/`awk` for Chart.yaml parsing instead of `yq` — no extra tooling needed in `alpine/helm`
- `concurrencyPolicy: Forbid` as default — safer for most cron workloads-
- Thanks the OCI approach, Jenkins CI will not need to use `helm repo index` for incremental index updates anymore

**Open threads:**

- `stateless-svc` chart relocation from overture/helm-charts → here (in progress)
- Chart list: other charts to consolidate from argo-charts and elsewhere

---

## 2026-06-01 — Initial devctx scaffolding

**Done:**

- Created `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `DEVELOPMENT.md`
- Created `.dev/` working documents: `roadmap.md`, `tech-debt.md`, `sessions.md`
- Updated `README.md` and `Makefile` to reference correct org (`oicr-softeng`) and GitHub Pages URL; replaced stale `icgc-argo` references and `helm3` with `helm`
- Created `docs/.gitkeep` placeholder (subsequently removed in favour of `gh-pages` branch approach)

**Decisions:**

- Publishing is manual for now (Makefile + GitHub Pages); CI automation is a roadmap item
- Charts scope TBD — scaffolding first

**Open threads:** Resolved in the same session.
