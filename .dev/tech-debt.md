# Tech Debt

<!-- Entry format:
| # | File/Location | Severity | Kind | Issue | Proposed fix | Standalone |
|---|--------------|----------|------|-------|-------------|-----------|
| 1 | path/to/file | low/med/high | stale-ref / type / design / test / docs | Description | Fix description | yes / no / needs-context |
-->

## cron-job

| # | File/Location | Severity | Kind | Issue | Proposed fix | Standalone |
|---|--------------|----------|------|-------|-------------|------------|
| 1 | `cron-job/Chart.yaml` | low | docs | Missing `icon` field — `helm lint` emits `[INFO] Chart.yaml: icon is recommended`. Add a URL to a hosted icon image. | Add `icon: <url>` to `Chart.yaml` | yes |
| 2 | `cron-job/templates/cronjob.yaml`, `cron-job/values.yaml` | low | type / design | `imagePullSecrets` accepts a single string and wraps it in one list entry. Kubernetes expects a list of `{name: ...}` objects; the current API can only specify one secret and is non-standard. | Change value to `imagePullSecrets: []` and template to `{{- with .Values.imagePullSecrets }}{{- toYaml . | nindent N }}{{- end }}` — standard Helm pattern. **Breaking change** — callers using the string form must update. | yes |
