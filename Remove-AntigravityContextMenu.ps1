<#
.SYNOPSIS
    Remove Antigravity from Windows context menu
.DESCRIPTION
    This script removes all Antigravity context menu entries:
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

Write-Host "Removing Antigravity context menu entries..." -ForegroundColor Cyan

# Registry command wrapper function
function Invoke-RegCommand {
    param ([string]$Arguments)
    $process = Start-Process -FilePath "reg.exe" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
    return $process.ExitCode -eq 0
}

# Define registry paths to remove
$RegistryPaths = @(
    @{ Path = "HKEY_CLASSES_ROOT\*\shell\Open with Antigravity"; Name = "file context menu" },
    @{ Path = "HKEY_CLASSES_ROOT\Directory\shell\Open with Antigravity"; Name = "folder context menu" },
    @{ Path = "HKEY_CLASSES_ROOT\Directory\Background\shell\Open with Antigravity"; Name = "folder background context menu" }
)

$RemovedCount = 0

foreach ($entry in $RegistryPaths) {
    Write-Host "Removing: $($entry.Name)..." -ForegroundColor Yellow
    if (Invoke-RegCommand "DELETE `"$($entry.Path)`" /f") {
        Write-Host "  [OK] Removed" -ForegroundColor Green
        $RemovedCount++
    }
    else {
        Write-Host "  [SKIP] Not found or already removed" -ForegroundColor Gray
    }
}

if ($RemovedCount -gt 0) {
    Write-Host "`n[OK] Successfully removed $RemovedCount Antigravity context menu entries!" -ForegroundColor Green
}
else {
    Write-Host "`n[WARN] No Antigravity context menu entries found, may have been already removed." -ForegroundColor Yellow
}

Write-Host "`n[TIP] To take effect immediately, restart Explorer:" -ForegroundColor Cyan
Write-Host "   Stop-Process -Name explorer -Force; Start-Process explorer" -ForegroundColor Gray

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
