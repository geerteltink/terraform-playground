# PowerShell script to follow logs from all terraform-k8s project pods in real-time
Write-Host "=== Following logs from all terraform-k8s project pods ===" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow

# Get all pods with the project label
$pods = kubectl get pods -l project=terraform-k8s --all-namespaces -o json | ConvertFrom-Json

if ($pods.items.Count -eq 0) {
    Write-Host "No pods found with label project=terraform-k8s" -ForegroundColor Yellow
    exit
}

# Build array of kubectl commands to run in parallel
$jobs = @()

foreach ($pod in $pods.items) {
    $podName = $pod.metadata.name
    $namespace = $pod.metadata.namespace
    $component = $pod.metadata.labels.component
    $tier = $pod.metadata.labels.tier
    
    Write-Host "Starting log tail for $podName (component: $component, tier: $tier)" -ForegroundColor Cyan
    
    # Start kubectl logs in background job
    $job = Start-Job -ScriptBlock {
        param($podName, $namespace, $component)
        kubectl logs -f $podName -n $namespace --prefix 2>$null
    } -ArgumentList $podName, $namespace, $component
    
    $jobs += $job
}

Write-Host "`nWatching logs from $($jobs.Count) pods. Press Ctrl+C to stop.`n" -ForegroundColor Green

try {
    # Keep running until Ctrl+C
    while ($true) {
        foreach ($job in $jobs) {
            $output = Receive-Job $job -ErrorAction SilentlyContinue
            if ($output) {
                Write-Host $output
            }
        }
        Start-Sleep -Milliseconds 100
    }
}
finally {
    Write-Host "`nStopping all log jobs..." -ForegroundColor Yellow
    $jobs | Stop-Job -ErrorAction SilentlyContinue
    $jobs | Remove-Job -ErrorAction SilentlyContinue
    Write-Host "All jobs stopped." -ForegroundColor Green
}
