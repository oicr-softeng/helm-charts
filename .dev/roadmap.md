# Roadmap

## Current focus

First chart (`cron-job`) added; pipeline wired; next steps are deploying the Jenkins job and verifying the first publish.

## Planned

### Structure
- [ ] Evaluate per-chart `tech-debt.md` files (inside each chart directory) vs. repo-level sections — revisit when 3+ charts have real entries; current repo-level `## chart-name` sections are the interim approach

## In progress

- [ ] Bootstrap `gh-pages` branch (one-time manual setup — see DEVELOPMENT.md)
- [ ] Configure GitHub Pages in repository settings (source: `gh-pages` branch, root folder)

## Planned

### Charts
- [ ] Define and document initial chart list
- [ ] Consolidate charts from argo-charts (clone)
- [ ] Relocate charts from other sources (details TBD — team controls all source repos)

### CI/CD
- [ ] Register job in `config-jenkins-instances` (`sweng-dev-cumulus_jenkins1/values.yaml`) and deploy — `Jenkinsfile` and `pipelineSoftEngBuildHelmCharts` are ready

### Future
- [ ] Add chart testing (`helm unittest` — design and implement after first successful pipeline run)
