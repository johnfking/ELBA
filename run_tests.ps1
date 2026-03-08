# Convenience script to run tests with proper environment setup

# Set LUABOTS_STUB_MQ to use the stub
$env:LUABOTS_STUB_MQ = "1"

# Check if busted is available
if (!(Get-Command busted -ErrorAction SilentlyContinue)) {
    Write-Host "Error: busted is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Run .\scripts\install_deps.ps1 to install dependencies" -ForegroundColor Yellow
    exit 1
}

# Run tests with any provided arguments
Write-Host "Running tests..." -ForegroundColor Green
busted -v $args
