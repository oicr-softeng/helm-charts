# stateless-svc migration guide

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
                  request: 1800s # max time from client request to response
                  backendRequest: 1800s # max time waiting for the backend; must be <= request
```

Both fields are optional and accept Gateway API duration strings (e.g. `"30s"`, `"5m"`).

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
