# PowerShell script to install Lua and busted on Windows
# Requires Chocolatey package manager

Write-Host "Installing Lua and busted test framework..." -ForegroundColor Green

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey is not installed. Please install it from https://chocolatey.org/" -ForegroundColor Red
    Write-Host "Or install Lua manually from https://github.com/rjpcomputing/luaforwindows/releases" -ForegroundColor Yellow
    exit 1
}

# Install Lua
Write-Host "Installing Lua..." -ForegroundColor Cyan
choco install lua -y

# Install LuaRocks
Write-Host "Installing LuaRocks..." -ForegroundColor Cyan
choco install luarocks -y

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Install busted
Write-Host "Installing busted test framework..." -ForegroundColor Cyan
luarocks install busted

Write-Host "`nInstallation complete!" -ForegroundColor Green
Write-Host "You may need to restart your terminal for PATH changes to take effect." -ForegroundColor Yellow
Write-Host "`nTo run tests, use: busted -v spec" -ForegroundColor Cyan
