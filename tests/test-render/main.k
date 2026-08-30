import models.ai.com.ops.hops.v1alpha1 as stacksv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

# ==============================================================================
# Unit tests for GatewayAPIStack XRD
#
# Philosophy: test YOUR API, not the chart's internals.
# - render/validate already checks Helm Release schema correctness
# - Tests verify XRD spec fields produce the expected Release shape
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: minimal claim renders the gateway-api-crds Helm release with
    # default chart version, namespace, and release name.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-gateway-api-crds"
        spec = {
            compositionPath = "apis/gatewayapistacks/composition.yaml"
            xrdPath = "apis/gatewayapistacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.GatewayAPIStack {
                metadata.name = "test-gw"
                spec.clusterName = "my-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "gateway-api-crds"
                    spec.forProvider = {
                        chart = {
                            name = "gateway-api-crds"
                            repository = "https://wiremind.github.io/wiremind-helm-charts"
                            # renovate: datasource=helm depName=gateway-api-crds registryUrl=https://wiremind.github.io/wiremind-helm-charts
                            version = "1.6.0"
                        }
                        namespace = "gateway-api"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: custom labels merge with the stack's defaults.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-labels-merged-with-defaults"
        spec = {
            compositionPath = "apis/gatewayapistacks/composition.yaml"
            xrdPath = "apis/gatewayapistacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.GatewayAPIStack {
                metadata.name = "labeled-gw"
                spec = {
                    clusterName = "my-cluster"
                    labels = {team = "platform", environment = "staging"}
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "gateway-api-crds"
                        labels = {
                            "hops.ops.com.ai/managed" = "true"
                            "hops.ops.com.ai/gatewayapistack" = "labeled-gw"
                            team = "platform"
                            environment = "staging"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: custom chartVersion propagates to the Helm release.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-chart-version-propagates"
        spec = {
            compositionPath = "apis/gatewayapistacks/composition.yaml"
            xrdPath = "apis/gatewayapistacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.GatewayAPIStack {
                metadata.name = "version-test"
                spec = {
                    clusterName = "my-cluster"
                    chartVersion = "1.4.0"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "gateway-api-crds"
                    spec.forProvider.chart.version = "1.4.0"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 4: custom namespace propagates to the Helm release.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-namespace-propagates"
        spec = {
            compositionPath = "apis/gatewayapistacks/composition.yaml"
            xrdPath = "apis/gatewayapistacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.GatewayAPIStack {
                metadata.name = "ns-test"
                spec = {
                    clusterName = "my-cluster"
                    namespace = "kube-system"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "gateway-api-crds"
                    spec.forProvider.namespace = "kube-system"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 5: helmProviderConfigRef defaults to clusterName.
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "helm-provider-config-defaults-to-cluster-name"
        spec = {
            compositionPath = "apis/gatewayapistacks/composition.yaml"
            xrdPath = "apis/gatewayapistacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = stacksv1alpha1.GatewayAPIStack {
                metadata.name = "provider-test"
                spec.clusterName = "prod-cluster"
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "gateway-api-crds"
                    spec.providerConfigRef = {
                        name = "prod-cluster"
                        kind = "ProviderConfig"
                    }
                }
            ]
        }
    }
]

items = _items
