# Sessions

## 2026-06-01 — Jenkins pipeline implemented

**Done:**
- Created `Jenkinsfile` calling `pipelineSoftEngBuildHelmCharts()` from the shared pipeline library
- Created `vars/pipelineSoftEngBuildHelmCharts.groovy` in `jenkins-pipeline-library`: adapts `pipelineDevopsBuildHelm` for the `oicr-softeng` org and `gh-pages` publishing branch; adds `apk add yq git` to fix the `yq` gap in `alpine/helm`; uses credential `github-app-oicr-softeng` and git identity `softeng@oicr.on.ca` / `SoftEng`
- Added job registration to `config-jenkins-instances/jenkins-instances/sweng-dev-cumulus_jenkins1/values.yaml` under `softeng/other/helm-charts`
- Updated roadmap: CI/CD pipeline item replaced with deploy/registration step

**Decisions:**
- Pipeline name `pipelineSoftEngBuildHelmCharts` (not `BuildHelm` — avoids implying we build Helm itself)
- Git identity `softeng@oicr.on.ca` / `SoftEng` — new, following pattern in `stepGitOperations.groovy`
- `yq` installed via `apk add` rather than baked into image or worked around with grep/awk

**Open threads:**
- Deploy the `config-jenkins-instances` change to register the job in Jenkins
- Bootstrap `gh-pages` branch (manual one-time setup — see DEVELOPMENT.md)
- GitHub Pages repo settings still need updating to `gh-pages` branch source

---

## 2026-06-01 — Switched to gh-pages branch; closed Arranger parity gap; created shared context memories

**Done:**
- Updated `CLAUDE.md` to close Arranger parity gap: added memory check step, instruction file integrity check step, improved session discipline language (no conversational activity in sessions.md), `.dev/` commit reminder, and global workflow pointer
- Switched from `docs/` folder to `gh-pages` branch for chart publishing — updated all agent docs, `DEVELOPMENT.md`, `README.md`, `Makefile`, and `CLAUDE.md` accordingly
- Removed `docs/.gitkeep` placeholder
- Updated `.dev/roadmap.md` and `.dev/sessions.md` to reflect gh-pages approach and chart consolidation context
- Created personal global roadmap at `~/.claude/roadmap.md`
- Created softeng and overture project context memories

**Decisions:**
- `gh-pages` branch (not `docs/` folder) for chart publishing: semantically cleaner, the standard Helm community approach, and enables Jenkins CI automation cleanly
- Jenkins CI will use `helm repo index --merge` for incremental index updates; builds will be serialized to avoid concurrent `gh-pages` push conflicts
- Chart consolidation is a reorganization task — team controls all source repos; details TBD

**Open threads:**
- Initial `gh-pages` branch bootstrap (one-time manual setup — see DEVELOPMENT.md)
- GitHub Pages repo settings need updating to `gh-pages` branch source
- Jenkinsfile design and implementation
- Which specific charts to consolidate from argo-charts and where relocations come from

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
