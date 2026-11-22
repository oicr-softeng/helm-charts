# stateless-svc migration guide

## 1.7.0 to 1.7.1

No values changes are required. A release that sets no `probes.startup` renders as on 1.7.0, but for the chart's version label.

### New: `probes.startup`, for a service slow to start listening

Kubernetes runs neither liveness nor readiness until the startup probe succeeds, so a slow start no longer needs a lenient liveness probe that would also be slow to restart a hung pod. `path` is required; the other fields take Kubernetes' defaults when left out.

```yaml
probes:
  startup:
    path: /ping
    periodSeconds: 10
    failureThreshold: 60   # with periodSeconds, the longest start allowed: 10 minutes
```

## 1.6.3 to 1.7.0

No values changes are required. A release that sets none of the new fields renders as on 1.6.3, but for the chart's version label.

### New: `configMaps`, files from values mounted where you say

Each entry names a ConfigMap, the directory its files go into, and the files themselves, one per key. Files for another directory go in another entry.

```yaml
configMaps:
  catalogues:                     # rendered as the ConfigMap <fullname>-catalogues
    path: /app/configs            # mounted here, read-only, in the main container
    files:
      auth.json: |
        { "enabled": true }
      biosamples.json: |
        { "index": "biosamples" }
  theme:
    path: /app/public/theme
    files:
      colours.css: "body {}"
```

- **A changed file restarts the pods.** A pod annotation, `checksum/configmaps`, hashes every entry's files and path, so the pods read the new content at their next start.
- **The mount replaces whatever the image had in that directory**, so point it at a directory holding nothing else the application needs.
- **A ConfigMap holds at most 1 MiB in total.**
- **Refused at render, naming the rule broken:** an entry name other than lowercase letters, digits and `-`, or longer than 53 characters; a path that isn't absolute; two entries sharing a path; an entry with no files; a file name holding anything but letters, digits, `-`, `_` and `.`, a subdirectory included; and content that isn't text, such as an unquoted number.

Terraform can fill an entry's `files` from a directory in the repository, so that adding a file there is the only edit:

```hcl
yamlencode({ configMaps = { catalogues = {
  path  = "/app/configs"
  files = { for f in fileset("${path.module}/catalogues", "*.json") : f => file("${path.module}/catalogues/${f}") }
} } })
```

### New: `mountSecrets[].secret.items`

A `mountSecrets` entry, for the main container or a sidecar, can now mount only chosen keys of a secret. List them under `secret.items`, in the form a Kubernetes secret volume takes. Without `items`, every key is mounted, as before, and the rendered output is unchanged.

```yaml
mountSecrets:
  - name: database-ca
    path: /etc/database-ca
    secret:
      secretName: database-cluster-ca
      items:
        - key: ca.crt
          path: ca.crt
```

Use it when a secret holds a key the pod must not have, such as a CA certificate kept beside the private key that signs with it. The mount stays a directory, so a changed value in the secret still reaches the running pod.

Two cases to know about:

- **A key listed in `items` that the secret doesn't hold stops the pod from starting,** since Kubernetes can't set up the volume.
- **Two entries that resolve to the same volume name render one volume,** with the first entry's `items` and `defaultMode`.

**Check before upgrading:** up to 1.6.3, the chart ignored everything under an entry's `secret:` key except `secretName`. A values file that already sets `secret.items` mounts only those keys from 1.7.0.

### Fixed: two or more `createSecrets` entries

Up to 1.6.3, two or more `createSecrets` entries rendered as one malformed manifest, so such a release could not be deployed. Each entry now renders as a Secret of its own. A release with one entry renders exactly as before.

## 1.6.2 to 1.6.3

### `service.port` defaults to `80` again, as before 1.6.0

In 1.6.0 through 1.6.2, `service.port` fell back to `container.port` when it was not set. That tied a Service's address to whatever port the application happened to listen on, so an in-cluster URL without a port, such as `http://my-svc`, stopped working whenever the container did not listen on 80. Almost no application does.

From 1.6.3, `service.port` defaults to `80`, as it did up to 1.5.x. The Service keeps reaching the container by port name, so `container.port` and the health probes are unaffected. Set `service.port` only when the Service must expose a different port. The HTTPRoute backend port follows `service.port`, and an Ingress refers to the port by name, so neither needs any change.

**Affects only deployments on 1.6.0 to 1.6.2 that relied on the fallback.** If a deployment did not set `service.port`, its Service listened on `container.port` and its callers may name that port in their URLs, for example `http://my-svc:3000`. After the upgrade the Service listens on 80, so choose one:

- Remove the port from the callers' URLs. This is the intended outcome.
- Or keep the callers as they are, and set `service.port` to the port they use.

Deployments that already set `service.port` explicitly are not affected. Deployments on 1.5.x or earlier already had the 80 default and need no change.

## 1.6.1 to 1.6.2

### Bug fixes (no values changes required)

Four bugs fixed across `_volumes.tpl` and `networkpolicy.yaml`:

- **Nil pointer on `mountSecrets` with `defaultMode`:** providing a `mountSecrets` (or sidecar `mountSecrets`) entry as a map with `defaultMode` (and no `secret.secretName` sub-key) caused a nil pointer panic at template render time. Affected both the main container and sidecar code paths. Fixed by using `dig` to safely traverse the optional `secret.secretName` field, falling back to the entry's `name` (same fix applied to the sidecar mount-path computation that derived the path from `secret.secretName`).
- **Nil pointer on `network.inbound.fromRouter: null`:** explicitly nulling `fromRouter` in values caused a nil pointer panic when the NetworkPolicy template read `fromRouter.namespace`. Fixed by extracting `$fromRouter := $inbound.fromRouter | default dict` before any field access.
- **Empty volume/mount names for non-shared emptyDirs:** scoping errors (`:=` instead of `=`) in three places meant the computed volume name was never assigned to the outer variable, producing empty strings in rendered `volumeMounts` and `volumes` blocks. Fixed in the main-container volumeMounts block, the sidecar volumeMounts block, and the volumes block (which also had a stray `| nindent 4` applied to the variable assignment itself, corrupting the name with leading whitespace).

### New: `network.gateway.rules[].timeouts`

HTTPRoute rules now support a `timeouts` block for controlling request and backend response durations:

```yaml
network:
    gateway:
        rules:
            - matches:
                  - path:
                        type: PathPrefix
                        value: /
              timeouts:
                  request: 1800s # max time for the gateway to respond; when the clock starts depends on the gateway
                  backendRequest: 1800s # max time waiting for the backend; must be <= request
```

Both fields are optional and accept Gateway API duration strings (e.g. `"30s"`, `"5m"`). What each gateway measures with them, and which gateways ignore them, is under "Timeouts and upload size" in the 1.5.x to 1.6.0 section below.

### New: full match criteria in `network.gateway.rules[].matches`

Rule matches previously only rendered the `path` field. They now pass through any valid HTTPRoute match field: `path`, `headers`, `method`, and `queryParams`.

```yaml
network:
    gateway:
        rules:
            - matches:
                  - path:
                        type: PathPrefix
                        value: /api
                    method: POST
                    headers:
                        - name: X-Api-Version
                          value: v2
```

---

## 1.6.0 to 1.6.1

### `service.portName`: service and container port name changed

The service port, container port, and Ingress backend port reference are now driven by `service.portName`, which defaults to `"service"`. Previously the port name was hardcoded to `"http"` across all three templates.

**NOTE** for any deployment that references the service port by name externally: for example, a custom NetworkPolicy or Ingress that targets `port.name: http` on this service. Update those references to `"service"`, or set `service.portName: http` in your values to restore the old name:

```yaml
service:
    portName: http # restore the previous hardcoded name
```

---

## 1.5.x to 1.6.0

Version 1.6.0 restructures all networking configuration under a single `network` top-level key, adds Gateway API support, and removes the fixed default for `service.port`. The changes are breaking for any deployment that configures ingress, network policies, or relied on `service.port` defaulting to 80 without setting it explicitly.

## Values that moved

### Ingress routing

All Kubernetes Ingress configuration moves from the top-level `ingress` key into `network.ingress`.

```yaml
# before (1.5.x)
ingress:
    annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod-a
    className: private
    hosts:
        - host: myapp.example.com
          paths:
              - path: /
                pathType: ImplementationSpecific
    tls:
        - hosts:
              - myapp.example.com
          secretName: myapp-tls

# after (1.6.0)
network:
    ingress:
        annotations:
            cert-manager.io/cluster-issuer: letsencrypt-prod-a
        className: private
        hosts:
            - host: myapp.example.com
              paths:
                  - path: /
                    pathType: ImplementationSpecific
        tls:
            - hosts:
                  - myapp.example.com
              secretName: myapp-tls
```

The Ingress is now rendered when `network.ingress` is present, rather than when `ingress.hosts` is non-empty.

### NetworkPolicy inbound rules

The `ingress.allowSameNamespace`, `ingress.pods`, and `ingress.cidrs` fields (which controlled NetworkPolicy inbound rules, not the Ingress resource) move to `network.inbound`.

```yaml
# before (1.5.x)
ingress:
    allowSameNamespace: true
    pods:
        - namespace: monitoring
          labels:
              - app.kubernetes.io/name: prometheus
          port: 8080
          protocol: TCP
    cidrs:
        - cidr: 10.0.0.0/24
          port: 8080

# after (1.6.0)
network:
    inbound:
        allowSameNamespace: true
        pods:
            - namespace: monitoring
              labels:
                  - app.kubernetes.io/name: prometheus
              port: 8080
              protocol: TCP
        cidrs:
            - cidr: 10.0.0.0/24
              port: 8080
```

### NetworkPolicy outbound rules

The `egress` top-level key moves to `network.outbound`.

```yaml
# before (1.5.x)
egress:
    allowSameNamespace: false
    pods:
        - namespace: postgres
          labels:
              - app.kubernetes.io/name: postgres
          port: 5432
          protocol: TCP

# after (1.6.0)
network:
    outbound:
        allowSameNamespace: false
        pods:
            - namespace: postgres
              labels:
                  - app.kubernetes.io/name: postgres
              port: 5432
              protocol: TCP
```

## Changed defaults

### `service.port` now defaults to `container.port`

**Superseded in 1.6.3:** `service.port` defaults to `80` again. See 1.6.2 to 1.6.3 above.

Previously `service.port` defaulted to `80`. It now defaults to `container.port` when not explicitly set, so setting `container.port` alone is sufficient for the common case where both ports match.

```yaml
# before (1.5.x): required both
container:
  port: 8080
service:
  port: 8080

# after (1.6.0): container.port is enough
container:
  port: 8080
```

Set `service.port` explicitly only when the Kubernetes Service must expose a different port than the container (e.g. service on 80, container on 8080).

**Breaking:** any deployment that relied on `service.port` defaulting to 80 without setting it explicitly will now get `container.port`'s value instead. Add `service.port: 80` explicitly to preserve the old behaviour.

## New fields

### `network.inbound.fromRouter`

Adds a NetworkPolicy inbound rule allowing the routing infrastructure (ingress controller or Gateway data plane) to reach this service. On default-deny clusters, this rule is required for traffic to flow when routing is configured. Previously this required a separate kustomize post-processing step.

```yaml
network:
    inbound:
        fromRouter:
            namespace: traefik-private
            podLabels:
                app.kubernetes.io/name: traefik
```

### `network.outbound.allowDns`

Adds an outbound rule permitting DNS resolution (port 53 UDP and TCP) to any destination. Required on default-deny clusters for services that perform hostname lookups.

```yaml
network:
    outbound:
        allowDns: true
```

### Optional ports on inbound and outbound rules

`port` is now optional on all rule types: `inbound.cidrs[]`, `inbound.pods[]`, `outbound.cidrs[]`, and `outbound.pods[]`. Omitting `port` generates a rule with no port restriction, allowing traffic on all ports.

```yaml
network:
    inbound:
        pods:
            - namespace: kube-backup # no port restriction
            - namespace: monitoring
              labels:
                  app.kubernetes.io/name: prometheus
              port: 8080 # port-restricted
    outbound:
        cidrs:
            - cidr: 0.0.0.0/0 # no port restriction
              except:
                  - 10.0.0.0/8
```

### Optional labels on pods rules

`labels` is now optional on `inbound.pods[]` and `outbound.pods[]`. Omitting `labels` generates a namespace-only selector (any pod in that namespace). This replaces the previous requirement to use a separate `namespaces[]` list.

To allow all pods in namespace A and only specific pods from namespace B, use two entries in the same list:

```yaml
network:
    inbound:
        pods:
            - namespace: kube-backup # any pod in kube-backup
            - namespace: monitoring
              labels:
                  app.kubernetes.io/name: prometheus # only prometheus in monitoring
              port: 8080
```

### `network.outbound.cidrs[].except`

Outbound CIDR rules now support an `except` field for excluding sub-ranges, enabling patterns like "allow all internet traffic except RFC-1918 ranges".

```yaml
network:
    outbound:
        cidrs:
            - cidr: 0.0.0.0/0
              port: 443
              except:
                  - 10.0.0.0/8
                  - 192.168.0.0/16
```

### Gateway API (`network.gateway`)

Alternative to `network.ingress` for clusters using Gateway API. Renders a `gateway.networking.k8s.io/v1 HTTPRoute`. Cannot be set at the same time as `network.ingress`.

```yaml
network:
    gateway:
        hosts:
            - myapp.example.com
        rules:
            - matches:
                  - path:
                        type: PathPrefix
                        value: /
              filters: []
```

The Gateway name defaults to `<release-name>-gateway`. Override with `network.gateway.name`.

#### TLS with Gateway API

TLS termination is configured on the Gateway listener, not in the chart. Remove any `cert-manager.io/cluster-issuer` annotation and `tls` block when migrating from `network.ingress` to `network.gateway`; configure the certificate on the Gateway resource instead.

#### Timeouts and upload size: what the Ingress annotations become

An Ingress controlled by ingress-nginx often carries annotations that size uploads and time requests, and an HTTPRoute has no annotations to carry them. So moving a service from `network.ingress` to `network.gateway` can change what it accepts unless each annotation is replaced on purpose:

| Ingress annotation | What it does on ingress-nginx | With `network.gateway` |
| --- | --- | --- |
| `nginx.ingress.kubernetes.io/proxy-body-size` | Rejects a request whose body is larger, with 413. Without it, the limit is nginx's default of 1m. | No chart field. Neither gateway below limits body size by default, so every upload the annotation allowed still gets through, and so does anything larger. |
| `nginx.ingress.kubernetes.io/proxy-read-timeout` | Closes the connection when the backend sends nothing for this long; it measures the gap between two reads, not the whole response. Default 60s. | `rules[].timeouts.request`, which bounds the whole response instead. Size it for the slowest complete response rather than copying the number. |
| `nginx.ingress.kubernetes.io/proxy-send-timeout` | The same, for the gap between two writes of the request to the backend. Default 60s. | `rules[].timeouts.request` as well; how much of an upload it covers depends on the gateway, as below. |

How each gateway treats the same route, from Envoy Gateway v1.8 and Traefik v3.6:

| | Envoy Gateway v1.8 | Traefik v3.6 |
| --- | --- | --- |
| Request body size | No limit by default. A `BackendTrafficPolicy` with `requestBuffer.limit` sets one; it holds each whole request in memory before forwarding it, so it suits small bodies, not large uploads. | No limit by default. A `Middleware` with `buffering.maxRequestBodyBytes`, referenced from `rules[].filters`, sets one. |
| `rules[].timeouts.request` | Starts once the whole upload has been received and ends when the response is complete, so a slow upload is never cut off by it. | Ignored: v3.6 does not read HTTPRoute timeouts. |
| Time to receive the whole upload | Unlimited, unless a `ClientTrafficPolicy` sets `timeouts.http.requestReceivedTimeout`. | Bounded by the entrypoint's `transport.respondingTimeouts.readTimeout`, 60s by default, which covers the entire request including its body. It is set where Traefik is installed, not in the chart. |

Policies such as `BackendTrafficPolicy`, `ClientTrafficPolicy` and Traefik's `Middleware` are not rendered by this chart, and some clusters reserve the Envoy Gateway ones for the platform team. Check with whoever runs the Gateway before relying on one.

**When migrating a service that takes uploads:**

1. Replace `proxy-read-timeout` and `proxy-send-timeout` with `rules[].timeouts.request`, set to the longest a complete response may take. On Traefik v3.6 that field has no effect, so a long upload depends on the entrypoint's `readTimeout` instead.
2. Make the service itself refuse bodies over the size it supports. `proxy-body-size` did that at the edge, and with no gateway default to replace it, the application is the one place the limit holds whichever gateway is in front.
3. Where a limit at the edge is still wanted, add it as a gateway policy, as in the table above. On Traefik, a Middleware in the release's namespace is referenced like this:

```yaml
network:
    gateway:
        rules:
            - matches:
                  - path:
                        type: PathPrefix
                        value: /
              filters:
                  - type: ExtensionRef
                    extensionRef:
                        group: traefik.io
                        kind: Middleware
                        name: limit-body-20m
```
