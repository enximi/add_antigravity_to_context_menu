<#
.SYNOPSIS
    Add Antigravity to Windows context menu
.DESCRIPTION
    This script adds "Open with Antigravity" option to:
    - File context menu
    - Folder context menu
    - Folder background context menu
.NOTES
    Requires administrator privileges, script will auto-elevate
#>

# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-File", $MyInvocation.MyCommand.Path)
    exit
}

$ErrorActionPreference = "Stop"

# Build Antigravity path
$AntigravityPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "Programs", "Antigravity", "Antigravity.exe")

# Check if Antigravity is installed
if (-not (Test-Path $AntigravityPath)) {
    Write-Host "[ERROR] Antigravity.exe not found. Please make sure Antigravity IDE is installed." -ForegroundColor Red
    Write-Host "Expected path: $AntigravityPath" -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
    exit 1
}

Write-Host "[OK] Detected Antigravity installation path: $AntigravityPath" -ForegroundColor Green

# Registry command wrapper function
function Invoke-RegCommand {
    param ([string]$Arguments)
    $process = Start-Process -FilePath "reg.exe" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Host "[ERROR] Registry command failed: reg.exe $Arguments" -ForegroundColor Red
        exit 1
    }
}

try {
    # Add file context menu
    Write-Host "Adding file context menu..." -ForegroundColor Cyan
    $filePath = "HKEY_CLASSES_ROOT\*\shell\Open with Antigravity"
    Invoke-RegCommand "ADD `"$filePath`" /ve /d `"Open with Antigravity`" /f"
    Invoke-RegCommand "ADD `"$filePath`" /v Icon /d `"$AntigravityPath`" /f"
    Invoke-RegCommand "ADD `"$filePath\command`" /ve /d `"\`"$AntigravityPath\`" \`"%1\`"`" /f"

    # Add folder context menu
    Write-Host "Adding folder context menu..." -ForegroundColor Cyan
    $folderPath = "HKEY_CLASSES_ROOT\Directory\shell\Open with Antigravity"
    Invoke-RegCommand "ADD `"$folderPath`" /ve /d `"Open with Antigravity`" /f"
    Invoke-RegCommand "ADD `"$folderPath`" /v Icon /d `"$AntigravityPath`" /f"
    Invoke-RegCommand "ADD `"$folderPath\command`" /ve /d `"\`"$AntigravityPath\`" \`"%1\`"`" /f"

    # Add folder background context menu
    Write-Host "Adding folder background context menu..." -ForegroundColor Cyan
    $backgroundPath = "HKEY_CLASSES_ROOT\Directory\Background\shell\Open with Antigravity"
    Invoke-RegCommand "ADD `"$backgroundPath`" /ve /d `"Open with Antigravity`" /f"
    Invoke-RegCommand "ADD `"$backgroundPath`" /v Icon /d `"$AntigravityPath`" /f"
    Invoke-RegCommand "ADD `"$backgroundPath\command`" /ve /d `"\`"$AntigravityPath\`" \`"%V\`"`" /f"

    Write-Host "`n[OK] Successfully added Antigravity to context menu!" -ForegroundColor Green
    Write-Host "You can now right-click on files, folders, or folder background to select 'Open with Antigravity'" -ForegroundColor Yellow
    Write-Host "`n[TIP] If menu doesn't appear immediately, restart Explorer:" -ForegroundColor Cyan
    Write-Host "   Stop-Process -Name explorer -Force; Start-Process explorer" -ForegroundColor Gray
}
catch {
    Write-Host "[ERROR] Error adding registry entries: $_" -ForegroundColor Red
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
