# 🖱️ Open with Antigravity Context Menu

[English](README.md)

为 Windows 右键菜单添加 "Open with Antigravity" 选项，让你可以快速使用 Antigravity IDE 打开文件和文件夹。

## ✨ 功能

添加 "Open with Antigravity" 选项到：

- 📄 文件右键菜单
- 📁 文件夹右键菜单
- 🖼️ 文件夹空白处右键菜单

## 🚀 安装

1. 下载 `Add-AntigravityContextMenu.ps1`
2. 右键点击脚本，选择 **"使用 PowerShell 运行"**
3. 如果弹出 UAC 提示，点击 **"是"** 允许管理员权限

安装完成后，右键菜单将显示 "Open with Antigravity" 选项 ✅

## 🗑️ 卸载

1. 下载 `Remove-AntigravityContextMenu.ps1`
2. 右键点击脚本，选择 **"使用 PowerShell 运行"**
3. 如果弹出 UAC 提示，点击 **"是"** 允许管理员权限

## 🔧 故障排除

### 脚本无法运行 (执行策略限制)

如果看到 `无法加载文件...` 的错误，需要临时修改执行策略：

```powershell
# 允许运行脚本
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# 运行完成后，重置为默认值
Set-ExecutionPolicy -ExecutionPolicy Default -Scope CurrentUser
```

### 右键菜单没有立即出现

重启 Windows 资源管理器：

```powershell
Stop-Process -Name explorer -Force; Start-Process explorer
```

或者注销并重新登录。

## 📝 说明

- 两个脚本都需要管理员权限（会自动请求）
- 默认 Antigravity 安装路径：`%LOCALAPPDATA%\Programs\Antigravity\Antigravity.exe`
- 如果安装在其他位置，需要修改脚本中的路径
- 脚本输出信息为英文

## 📄 License

MIT License
