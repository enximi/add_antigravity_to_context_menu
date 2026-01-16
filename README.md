# 🖱️ Open with Antigravity Context Menu

Add "Open with Antigravity" option to Windows context menu for quickly opening files and folders with Antigravity IDE.

[中文说明](README.zh-CN.md)

## ✨ Features

Adds "Open with Antigravity" option to:

- 📄 File context menu
- 📁 Folder context menu
- 🖼️ Folder background context menu (right-click in empty area)

## 🚀 Installation

1. Download `Add-AntigravityContextMenu.ps1`
2. Right-click the script and select **"Run with PowerShell"**
3. If UAC prompt appears, click **"Yes"** to allow administrator privileges

After installation, "Open with Antigravity" option will appear in your context menu ✅

## 🗑️ Uninstallation

1. Download `Remove-AntigravityContextMenu.ps1`
2. Right-click the script and select **"Run with PowerShell"**
3. If UAC prompt appears, click **"Yes"** to allow administrator privileges

## 🔧 Troubleshooting

### Script won't run (Execution Policy)

If you see `cannot be loaded because running scripts is disabled...` error, temporarily change execution policy:

```powershell
# Allow running scripts
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# After done, reset to default
Set-ExecutionPolicy -ExecutionPolicy Default -Scope CurrentUser
```

### Context menu doesn't appear immediately

Restart Windows Explorer:

```powershell
Stop-Process -Name explorer -Force; Start-Process explorer
```

Or sign out and sign back in.

## 📝 Notes

- Both scripts require administrator privileges (auto-elevated)
- Default Antigravity installation path: `%LOCALAPPDATA%\Programs\Antigravity\Antigravity.exe`
- If installed elsewhere, modify the path in the script

## 📄 License

MIT License
