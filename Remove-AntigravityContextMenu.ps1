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

# Language detection - check if system language is Chinese
$IsChinese = (Get-Culture).Name -like "zh-*"

# Localized messages
$Messages = @{
    Removing        = if ($IsChinese) { "正在移除 Antigravity 右键菜单项..." } else { "Removing Antigravity context menu entries..." }
    RemovingFile    = if ($IsChinese) { "正在移除: 文件右键菜单..." } else { "Removing: file context menu..." }
    RemovingFolder  = if ($IsChinese) { "正在移除: 文件夹右键菜单..." } else { "Removing: folder context menu..." }
    RemovingBg      = if ($IsChinese) { "正在移除: 文件夹空白处右键菜单..." } else { "Removing: folder background context menu..." }
    Removed         = if ($IsChinese) { "  ✅ 已移除" } else { "  ✅ Removed" }
    NotFound        = if ($IsChinese) { "  ⚠️ 未找到或已移除" } else { "  ⚠️ Not found or already removed" }
    SuccessCount    = if ($IsChinese) { "✅ 成功移除 {0} 个 Antigravity 右键菜单项！" } else { "✅ Successfully removed {0} Antigravity context menu entries!" }
    NoneFound       = if ($IsChinese) { "⚠️ 未找到任何 Antigravity 右键菜单项，可能已被移除。" } else { "⚠️ No Antigravity context menu entries found, may have been already removed." }
    RestartTip      = if ($IsChinese) { "💡 提示: 如需立即生效，请重启资源管理器：" } else { "💡 Tip: To take effect immediately, restart Explorer:" }
    PressAnyKey     = if ($IsChinese) { "按任意键退出..." } else { "Press any key to exit..." }
}

Write-Host $Messages.Removing -ForegroundColor Cyan

# Registry command wrapper function
function Invoke-RegCommand {
    param ([string]$Arguments)
    $process = Start-Process -FilePath "reg.exe" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
    return $process.ExitCode -eq 0
}

# Define registry paths to remove
$RegistryPaths = @(
    @{ Path = "HKEY_CLASSES_ROOT\*\shell\Open with Antigravity"; Msg = $Messages.RemovingFile },
    @{ Path = "HKEY_CLASSES_ROOT\Directory\shell\Open with Antigravity"; Msg = $Messages.RemovingFolder },
    @{ Path = "HKEY_CLASSES_ROOT\Directory\Background\shell\Open with Antigravity"; Msg = $Messages.RemovingBg }
)

$RemovedCount = 0

foreach ($entry in $RegistryPaths) {
    Write-Host $entry.Msg -ForegroundColor Yellow
    if (Invoke-RegCommand "DELETE `"$($entry.Path)`" /f") {
        Write-Host $Messages.Removed -ForegroundColor Green
        $RemovedCount++
    }
    else {
        Write-Host $Messages.NotFound -ForegroundColor Gray
    }
}

if ($RemovedCount -gt 0) {
    Write-Host ("`n" + ($Messages.SuccessCount -f $RemovedCount)) -ForegroundColor Green
}
else {
    Write-Host "`n$($Messages.NoneFound)" -ForegroundColor Yellow
}

Write-Host "`n$($Messages.RestartTip)" -ForegroundColor Cyan
Write-Host "   Stop-Process -Name explorer -Force; Start-Process explorer" -ForegroundColor Gray

Write-Host "`n$($Messages.PressAnyKey)"
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
