# start-dev-environment.ps1
# DevOps E-Commerce Platform - local development environment starter

$ErrorActionPreference = "Stop"

$ProjectPath = "C:\Users\Rajesh.Borugadda\OneDrive - SYNECTIKS INC\Desktop\Project Sep\devops-ecommerce-platform"
$RunnerPath  = "C:\actions-runner"

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " DevOps E-Commerce Platform - Startup" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

Write-Host "`n[1/5] Checking Kubernetes..." -ForegroundColor Yellow
kubectl get nodes
if ($LASTEXITCODE -ne 0) {
    throw "Kubernetes is not available. Start Docker Desktop/Kubernetes first."
}

Write-Host "`n[2/5] Checking monitoring and ecommerce namespaces..." -ForegroundColor Yellow
kubectl get pods -n monitoring
kubectl get pods -n ecommerce

function Test-PortListening {
    param([int]$Port)
    return $null -ne (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
}

function Start-PortForwardWindow {
    param(
        [string]$Title,
        [string]$Command
    )
    Write-Host "Starting $Title..." -ForegroundColor Green
    Start-Process powershell.exe -ArgumentList @(
        "-NoExit",
        "-Command",
        "`$Host.UI.RawUI.WindowTitle='$Title'; $Command"
    )
}

Write-Host "`n[3/5] Starting Prometheus access..." -ForegroundColor Yellow
if (Test-PortListening 9090) {
    Write-Host "Port 9090 is already listening. Skipping Prometheus port-forward." -ForegroundColor DarkYellow
} else {
    Start-PortForwardWindow `
        -Title "Prometheus - localhost:9090" `
        -Command "kubectl port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090 -n monitoring"
}

Write-Host "`n[4/5] Starting Grafana and Product Service access..." -ForegroundColor Yellow
if (Test-PortListening 3000) {
    Write-Host "Port 3000 is already listening. Skipping Grafana port-forward." -ForegroundColor DarkYellow
} else {
    Start-PortForwardWindow `
        -Title "Grafana - localhost:3000" `
        -Command "kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
}

if (Test-PortListening 8088) {
    Write-Host "Port 8088 is already listening. Skipping Product Service port-forward." -ForegroundColor DarkYellow
} else {
    Start-PortForwardWindow `
        -Title "Product Service - localhost:8088" `
        -Command "kubectl port-forward svc/product-service 8088:8080 -n ecommerce"
}

Write-Host "`n[5/5] Checking GitHub Actions self-hosted runner..." -ForegroundColor Yellow
$runnerProcess = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
    Where-Object {
        $_.CommandLine -and $_.CommandLine -like "*C:\actions-runner*"
    }

if ($runnerProcess) {
    Write-Host "GitHub Actions runner appears to be running. Skipping startup." -ForegroundColor Green
} else {
    if (-not (Test-Path "$RunnerPath\run.cmd")) {
        throw "GitHub Actions runner was not found at $RunnerPath"
    }

    Start-Process powershell.exe -WorkingDirectory $RunnerPath -ArgumentList @(
        "-NoExit",
        "-Command",
        "`$Host.UI.RawUI.WindowTitle='GitHub Actions Runner'; Set-Location '$RunnerPath'; .\run.cmd"
    )

    Write-Host "GitHub Actions runner startup window opened." -ForegroundColor Green
}

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Startup commands launched" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Grafana:          http://localhost:3000"
Write-Host "Prometheus:       http://localhost:9090"
Write-Host "Product Service:  http://localhost:8088"
Write-Host ""
Write-Host "Verify with:"
Write-Host "  kubectl get pods -n ecommerce"
Write-Host "  kubectl get pods -n monitoring"
Write-Host ""
Write-Host "Startup complete." -ForegroundColor Green
