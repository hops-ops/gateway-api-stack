# gateway-api-stack

Single-claim install of the [Kubernetes Gateway API CRDs](https://gateway-api.sigs.k8s.io/) (`gateway.networking.k8s.io`) onto a target Kubernetes cluster.

Cloud-neutral, controller-neutral. Provides the prerequisite CRDs for any Gateway API based controller (Istio Ambient, Envoy Gateway, Cilium Gateway, kgateway) and integrations that consume HTTPRoutes (Knative `net-gateway-api`, ExternalDNS `gateway-httproute` source, cert-manager Gateway issuance).

## Why a separate stack

Gateway API CRDs are a hard prerequisite that cuts across multiple platform stacks. Bundling them into istio-stack would couple every consumer to that stack's lifecycle; installing them by hand makes upgrades easy to forget. A small dedicated stack keeps the prereq explicit and version-pinned in one place.

## Usage

```yaml
apiVersion: hops.ops.com.ai/v1alpha1
kind: GatewayAPIStack
metadata:
  name: gateway-api
  namespace: default
spec:
  clusterName: my-cluster
```

This composes a single Helm release of [`wiremind/gateway-api-crds`](https://artifacthub.io/packages/helm/wiremind/gateway-api-crds), a community-maintained wrapper around the upstream CRD YAML from [`kubernetes-sigs/gateway-api`](https://github.com/kubernetes-sigs/gateway-api).

The chart's `appVersion` tracks the upstream Gateway API release. Bump `chartVersion` on the XR to upgrade.

## Spec Reference

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `clusterName` | string | _required_ | Target cluster name; default for `helmProviderConfigRef.name` |
| `namespace` | string | `gateway-api` | Namespace for the Helm release |
| `releaseName` | string | `gateway-api-crds` | Helm release name |
| `chartVersion` | string | `1.5.1` | wiremind/gateway-api-crds chart version (tracks upstream Gateway API) |
| `helmProviderConfigRef.name` | string | `clusterName` | Helm ProviderConfig |
| `helmProviderConfigRef.kind` | enum | `ProviderConfig` | `ProviderConfig` or `ClusterProviderConfig` |
| `values` | object | — | Helm values merged with chart defaults |
| `overrideAllValues` | object | — | Helm values that replace all defaults |
| `managementPolicies` | string[] | `["*"]` | Crossplane management policies |
| `labels` | object | — | Custom labels merged with defaults |

## Composed Resources

| Resource | Kind |
|---|---|
| `<releaseName>` | `helm.m.crossplane.io/Release` |

## Consumed By

- [`istio-stack`](https://github.com/hops-ops/istio-stack) — `Gateway` resource attached to the istio ambient `GatewayClass`
- [`knative-stack`](https://github.com/hops-ops/knative-stack) — emits `HTTPRoute` resources via `net-gateway-api`
- [`cloudflare-dns-stack`](https://github.com/hops-ops/cloudflare-dns-stack) — ExternalDNS `gateway-httproute` source

## Dependencies

| Kind | Package | Version |
|---|---|---|
| Function | `crossplane-contrib/function-auto-ready` | `>=v0.6.3` |
| Provider | `crossplane-contrib/provider-helm` | `>=v1` |

## Development

```bash
make render             # Render all examples
make validate           # Validate against Crossplane schemas
make test               # Run KCL unit tests
make e2e                # Run E2E test on a kind cluster
make build              # Build the package
```

## License

Apache-2.0
