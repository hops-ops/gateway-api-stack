### What's changed in v0.1.0

* feat: gateway-api-stack — install Kubernetes Gateway API CRDs as a Helm release (by @patrickleet)

  Cloud-neutral, controller-neutral. Single Helm release wrapping the upstream
  gateway.networking.k8s.io CRDs (chart: wiremind/gateway-api-crds).

  Provides the prereq CRDs for Gateway API based controllers (Istio Ambient,
  Envoy Gateway, Cilium Gateway) and integrations (Knative net-gateway-api,
  ExternalDNS gateway-httproute source, cert-manager Gateway issuance).

  - XRD: hops.ops.com.ai/v1alpha1 GatewayAPIStack (k8s/gateway-api group, no cloud coupling)
  - Composition: one helm.m.crossplane.io Release
  - Tests: 5 unit (test-render), e2e on a kind cluster
  - CI: on-pr / on-push-main / on-version-tagged via unbounded-tech reusable workflows


