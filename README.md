# helm-charts

Helm Charts server for the OICR Software Engineering team, published as OCI artifacts to GitHub Container Registry.

> **Note:** GitHub displays a Docker pull command on the package page — ignore it.
> These are Helm charts, not container images. See [Using a chart](#using-a-chart) below.

## How it works

Chart source lives on `main`. Jenkins CI packages and publishes charts to GHCR automatically on every push.

To add or update a chart: push changes to `main` and Jenkins handles the rest.

## Available charts

| Chart | Description |
|-------|-------------|
| `cron-job` | Generic chart to run a cron job |

## Using a chart

```shell
# Install directly
helm install <release-name> oci://ghcr.io/oicr-softeng/helm-charts/<chart-name> --version <version>

# Or pull first
helm pull oci://ghcr.io/oicr-softeng/helm-charts/<chart-name> --version <version>
```

Example:

```shell
helm install my-job oci://ghcr.io/oicr-softeng/helm-charts/cron-job --version 1.2.1
```
