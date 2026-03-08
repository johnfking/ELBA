# PowerShell script to install LuaJIT and busted on Windows
# Requires Chocolatey package manager

Write-Host "Installing LuaJIT and test dependencies..." -ForegroundColor Green

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Please install it from https://chocolatey.org/" -ForegroundColor Red
    Write-Host "Or install LuaJIT manually from https://luajit.org/" -ForegroundColor Yellow
    exit 1
}

# Install LuaJIT
Write-Host "Installing LuaJIT..." -ForegroundColor Cyan
choco install luajit -y

# Install LuaRocks
Write-Host "Installing LuaRocks..." -ForegroundColor Cyan
choco install luarocks -y

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install busted
Write-Host "Installing busted test framework and luacov..." -ForegroundColor Cyan
luarocks install busted
luarocks install luacov

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
Write-Host "`nTo run tests:" -ForegroundColor Cyan
Write-Host "  busted -v spec              # Run all tests" -ForegroundColor Cyan
Write-Host "  busted -v spec --coverage   # Run with coverage" -ForegroundColor Cyan
