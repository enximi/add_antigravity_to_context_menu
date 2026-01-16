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

# Language detection - check if system language is Chinese
$IsChinese = (Get-Culture).Name -like "zh-*"

# Localized messages
$Messages = @{
    NotFound        = if ($IsChinese) { "❌ 未找到 Antigravity.exe，请确认已安装 Antigravity IDE。" } else { "❌ Antigravity.exe not found. Please make sure Antigravity IDE is installed." }
    ExpectedPath    = if ($IsChinese) { "预期路径" } else { "Expected path" }
    PressAnyKey     = if ($IsChinese) { "按任意键退出..." } else { "Press any key to exit..." }
    DetectedPath    = if ($IsChinese) { "✅ 检测到 Antigravity 安装路径" } else { "✅ Detected Antigravity installation path" }
    AddingFile      = if ($IsChinese) { "正在添加文件右键菜单..." } else { "Adding file context menu..." }
    AddingFolder    = if ($IsChinese) { "正在添加文件夹右键菜单..." } else { "Adding folder context menu..." }
    AddingBg        = if ($IsChinese) { "正在添加文件夹空白处右键菜单..." } else { "Adding folder background context menu..." }
    Success         = if ($IsChinese) { "✅ 成功添加 Antigravity 到右键菜单！" } else { "✅ Successfully added Antigravity to context menu!" }
    Hint            = if ($IsChinese) { "现在你可以在文件、文件夹或文件夹空白处右键选择 'Open with Antigravity'" } else { "You can now right-click on files, folders, or folder background to select 'Open with Antigravity'" }
    RestartTip      = if ($IsChinese) { "💡 提示: 如果菜单没有立即出现，请重启资源管理器：" } else { "💡 Tip: If menu doesn't appear immediately, restart Explorer:" }
    RegError        = if ($IsChinese) { "❌ 注册表命令执行失败" } else { "❌ Registry command failed" }
    Error           = if ($IsChinese) { "❌ 添加注册表项时出错" } else { "❌ Error adding registry entries" }
}

# Build Antigravity path using proper path combination
$AntigravityPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "Programs", "Antigravity", "Antigravity.exe")

# Check if Antigravity is installed
if (-not (Test-Path $AntigravityPath)) {
    Write-Host $Messages.NotFound -ForegroundColor Red
    Write-Host "$($Messages.ExpectedPath): $AntigravityPath" -ForegroundColor Yellow
    Write-Host "`n$($Messages.PressAnyKey)"
    $null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
    exit 1
}

Write-Host "$($Messages.DetectedPath): $AntigravityPath" -ForegroundColor Green

# Registry command wrapper function
function Invoke-RegCommand {
    param ([string]$Arguments)
    $process = Start-Process -FilePath "reg.exe" -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Host "$($Messages.RegError): reg.exe $Arguments" -ForegroundColor Red
        exit 1
    }
}

try {
    # Add file context menu
    Write-Host $Messages.AddingFile -ForegroundColor Cyan
    $filePath = "HKEY_CLASSES_ROOT\*\shell\Open with Antigravity"
    Invoke-RegCommand "ADD `"$filePath`" /ve /d `"Open with Antigravity`" /f"
    Invoke-RegCommand "ADD `"$filePath`" /v Icon /d `"$AntigravityPath`" /f"
    Invoke-RegCommand "ADD `"$filePath\command`" /ve /d `"\`"$AntigravityPath\`" \`"%1\`"`" /f"

    # Add folder context menu
    Write-Host $Messages.AddingFolder -ForegroundColor Cyan
    $folderPath = "HKEY_CLASSES_ROOT\Directory\shell\Open with Antigravity"
    Invoke-RegCommand "ADD `"$folderPath`" /ve /d `"Open with Antigravity`" /f"
    Invoke-RegCommand "ADD `"$folderPath`" /v Icon /d `"$AntigravityPath`" /f"
    Invoke-RegCommand "ADD `"$folderPath\command`" /ve /d `"\`"$AntigravityPath\`" \`"%1\`"`" /f"

    # Add folder background context menu
    Write-Host $Messages.AddingBg -ForegroundColor Cyan
    $backgroundPath = "HKEY_CLASSES_ROOT\Directory\Background\shell\Open with Antigravity"
    Invoke-RegCommand "ADD `"$backgroundPath`" /ve /d `"Open with Antigravity`" /f"
    Invoke-RegCommand "ADD `"$backgroundPath`" /v Icon /d `"$AntigravityPath`" /f"
    Invoke-RegCommand "ADD `"$backgroundPath\command`" /ve /d `"\`"$AntigravityPath\`" \`"%V\`"`" /f"

    Write-Host "`n$($Messages.Success)" -ForegroundColor Green
    Write-Host $Messages.Hint -ForegroundColor Yellow
    Write-Host "`n$($Messages.RestartTip)" -ForegroundColor Cyan
    Write-Host "   Stop-Process -Name explorer -Force; Start-Process explorer" -ForegroundColor Gray
}
catch {
    Write-Host "$($Messages.Error): $_" -ForegroundColor Red
}

Write-Host "`n$($Messages.PressAnyKey)"
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
