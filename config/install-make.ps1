# Install Make on Windows PowerShell
# This script installs Chocolatey (if needed) and then installs Make

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Installing Make for Windows" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Check if Make is already installed
$makeInstalled = Get-Command make -ErrorAction SilentlyContinue

if ($makeInstalled -and -not $Force) {
    Write-Host "✓ Make is already installed at: $($makeInstalled.Source)" -ForegroundColor Green
    Write-Host "  Version: $(make --version | Select-Object -First 1)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Use -Force to reinstall" -ForegroundColor Yellow
    exit 0
}

Write-Host "Step 1/3: Checking Chocolatey..." -ForegroundColor Yellow

# Check if Chocolatey is installed
$chocoInstalled = Get-Command choco -ErrorAction SilentlyContinue

if (-not $chocoInstalled) {
    Write-Host "  Installing Chocolatey..." -ForegroundColor Gray
    
    # Install Chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    
    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "  ✓ Chocolatey installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "  ✗ Failed to install Chocolatey" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        exit 1
    }
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
else {
    Write-Host "  ✓ Chocolatey is already installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2/3: Installing Make..." -ForegroundColor Yellow

try {
    choco install make -y
    Write-Host "  ✓ Make installed successfully" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Failed to install Make" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3/3: Verifying installation..." -ForegroundColor Yellow

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify Make installation
$makeInstalled = Get-Command make -ErrorAction SilentlyContinue

if ($makeInstalled) {
    Write-Host "  ✓ Make is now available" -ForegroundColor Green
    Write-Host "  Location: $($makeInstalled.Source)" -ForegroundColor Gray
    
    # Get Make version
    $makeVersion = & make --version 2>&1 | Select-Object -First 1
    Write-Host "  Version: $makeVersion" -ForegroundColor Gray
}
else {
    Write-Host "  ✗ Make installation verification failed" -ForegroundColor Red
    Write-Host "  You may need to restart PowerShell or your computer" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now use 'make' command in PowerShell" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Close and reopen PowerShell (to refresh environment)" -ForegroundColor Gray
Write-Host "  2. Navigate to the config folder" -ForegroundColor Gray
Write-Host "  3. Run 'make help' to see available commands" -ForegroundColor Gray
Write-Host "  4. Run 'make setup' to setup development environment" -ForegroundColor Gray
Write-Host "  5. Run 'make deploy-customer' to deploy" -ForegroundColor Gray
Write-Host ""
