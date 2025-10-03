# PowerShell script to get logs from all terraform-k8s project pods
Write-Host "=== Getting logs from all terraform-k8s project pods ===" -ForegroundColor Green

# Get all pods with the project label
$pods = kubectl get pods -l project=terraform-k8s --all-namespaces -o json | ConvertFrom-Json

if ($pods.items.Count -eq 0) {
    Write-Host "No pods found with label project=terraform-k8s" -ForegroundColor Yellow
    exit
}

foreach ($pod in $pods.items) {
    $podName = $pod.metadata.name
    $namespace = $pod.metadata.namespace
    $component = $pod.metadata.labels.component
    $tier = $pod.metadata.labels.tier
    
    Write-Host "`n=== Logs from $podName (component: $component, tier: $tier) ===" -ForegroundColor Cyan
    
    try {
        kubectl logs $podName -n $namespace --tail=10 | ForEach-Object { Write-Host $_ }
        Write-Host "`n" # Add explicit newlines after logs
    }
    catch {
        Write-Host "Error getting logs from $podName in namespace $namespace" -ForegroundColor Red
    }
}

Write-Host "`n=== End of logs ===" -ForegroundColor Green
