resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.1"
  namespace  = "kube-system"

  # For local development with kind/self-signed certificates
  set {
    name  = "args"
    value = "{--cert-dir=/tmp,--secure-port=10250,--kubelet-preferred-address-types=InternalIP\\,ExternalIP\\,Hostname,--kubelet-use-node-status-port,--metric-resolution=15s,--kubelet-insecure-tls}"
  }

  set {
    name  = "metrics.enabled"
    value = "false"
  }

  wait          = true
  wait_for_jobs = false
  timeout       = 300
}
