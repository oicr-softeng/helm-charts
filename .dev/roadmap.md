# Roadmap

## Current focus

Four charts published to GHCR; pipeline stable. Next: `helm unittest` design and implementation.

## Planned

### Testing
- [ ] Add chart unit testing (`helm unittest`) — design and implement per-chart test suites

### kafka-operator-resources
- [ ] Add native `KafkaTopic` CR template — currently consumers (e.g. overture/infra) create topics via kustomize postrender manifests; the chart should own topic creation so deployments stay self-contained
- [ ] Add Gateway API (HTTPRoute) support — same pattern as stateless-svc 1.6.0

### Structure
- [ ] Evaluate per-chart `tech-debt.md` files (inside each chart directory) vs. repo-level sections — revisit when 3+ charts have real entries
