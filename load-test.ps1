# Simple load test script for HPA testing
Write-Host "Starting load test on APIs..."

$endpoints = @(
    "http://dev.elt.ink/api/one/",
    "http://dev.elt.ink/api/two/", 
    "http://dev.elt.ink/"
)

Write-Host "Sending requests for 2 minutes to trigger HPA scaling..."

$startTime = Get-Date
$endTime = $startTime.AddMinutes(2)

$requestCount = 0

while ((Get-Date) -lt $endTime) {
    foreach ($endpoint in $endpoints) {
        try {
            for ($i = 1; $i -le 10; $i++) {
                $response = Invoke-WebRequest -Uri $endpoint -TimeoutSec 1 -UseBasicParsing
                $requestCount++
                if ($requestCount % 50 -eq 0) {
                    Write-Host "Sent $requestCount requests..."
                }
            }
        }
        catch {
            # Ignore errors and continue
        }
    }
    Start-Sleep -Milliseconds 100
}

Write-Host "Load test completed. Sent $requestCount total requests."
Write-Host "Check HPA status with: kubectl get hpa -n k8s-example"