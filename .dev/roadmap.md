# Roadmap

## Current focus

Four charts published to GHCR; pipeline stable. Next: `helm unittest` design and implementation.

## Planned

### Testing
- [ ] Add chart unit testing (`helm unittest`) — design and implement per-chart test suites

### kafka-operator-resources
- [ ] Add native `KafkaTopic` CR template — currently consumers (e.g. overture/infra) create topics via kustomize postrender manifests; the chart should own topic creation so deployments stay self-contained
- [ ] Add Gateway API (HTTPRoute) support — same pattern as stateless-svc 1.6.0

### stateless-svc
- [ ] Add an `extraObjects` value for rendering extra manifests alongside a release, so consumers stop shipping them through kustomize postrender hooks
- [ ] Document the HTTPRoute timeouts in the chart README
- [ ] Document how the HTTPRoute hostname and TLS relate to the Gateway listener, which owns the certificate
- [ ] Document the OCI registry as the canonical way to consume the chart
- [x] ConfigMap support, as `configMaps`: each entry names a ConfigMap, the directory its files go into and the files, and a hash of every entry on the pod restarts the pods when a file changes. Secrets the chart creates stay out of that hash, since it sits in the pod spec, where more people can read it than can read Secrets. Overture's charts are to be retired in favour of this one, and Arranger's search server, which reads a directory of config files per catalogue, can now move off overture's `arranger` chart

### Structure
- [ ] Evaluate per-chart `tech-debt.md` files (inside each chart directory) vs. repo-level sections — revisit when 3+ charts have real entries
