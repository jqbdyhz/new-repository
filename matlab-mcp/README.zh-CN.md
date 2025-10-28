## 项目简介

MATLAB MCP Server 是一个 Model Context Protocol（MCP）服务器，用于把 MATLAB 的执行能力（通过 MATLAB Engine for Python）暴露给支持 MCP 的客户端（如 Codex CLI）。

本仓库已适配 Windows + Codex 的使用场景，并提供了快速配置、验证与打包发布的流程。

---

## 环境与前置条件（Windows）

- Windows 10/11 x64
- MATLAB 安装（建议 R2024b 或兼容版本），例如：`D:\matlab2024b`
- Python 3.11（MATLAB Engine 目前不支持 3.12/3.13）
- `uv` 包管理器（已在本机可用）
- Codex CLI（已安装）
- PowerShell 7（pwsh，已在本机配置为 Codex 默认 shell）

> 重要：请将 `MATLAB_PATH` 指向 MATLAB 安装“根目录”，而不是 `matlab.exe`。
> 示例：`MATLAB_PATH=D:\matlab2024b`

---

## 目录结构

- `matlab_server.py`：MCP 服务器主进程
- `matlab_scripts/`：存放由 MCP 工具创建/调用的 MATLAB 脚本与函数
- `pyproject.toml`：Python 项目配置，限定 Python 版本为 3.11
- `README.md`：上游英文文档
- `README.zh-CN.md`：本中文文档（你当前阅读的文件）
- `scripts/pack.ps1`：一键打包脚本（见下文）
- `output/`：样例运行输出目录（如导出的图像）

---

## 快速开始（与 Codex 集成）

1) 确认 MATLAB 安装根目录存在引擎路径：`%MATLAB_PATH%\extern\engines\python`

2) 在 Codex 中注册（已为你完成，若需要手动）：

```powershell
codex mcp add matlab --env MATLAB_PATH=D:\matlab2024b uv --directory D:\OneDrive\MCP\matlab-mcp run matlab_server.py
```

验证：

```powershell
codex mcp get matlab
codex mcp list
```

3) 运行 Codex（已将 shell 统一为 `pwsh`，UTF-8 输出不乱码）：

```powershell
codex
```

随后你即可在会话中直接请求我使用 MATLAB 工具。例如：

- 创建脚本：`create_matlab_script`
- 创建函数：`create_matlab_function`
- 执行脚本：`execute_matlab_script`
- 调用函数：`call_matlab_function`

我会通过 MCP 与 MATLAB 交互，并把运行结果（文本、图像等）返回给你。

---

## 本地快速自测（不经 MCP）

仓库内包含示例函数 `matlab_scripts/plot_sine_2hz_a2.m`，可直接用 MATLAB 批处理测试：

```powershell
$matlab = "D:\matlab2024b\bin\matlab.exe"
$scripts = "D:\OneDrive\MCP\matlab-mcp\matlab_scripts"
$out =     "D:\OneDrive\MCP\matlab-mcp\output\sine_2hz_a2.png"
$cmd = "try, addpath('$scripts'), plot_sine_2hz_a2('$out'), catch e, disp(getReport(e)), exit(1), end"
& $matlab -batch $cmd
```

生成的图像位于：`output\sine_2hz_a2.png`。

---

## 常见问题

1) MATLAB Engine 安装失败

- 首次运行服务器时会自动根据 `MATLAB_PATH` 安装引擎。
- 若失败可手动安装（Python 3.11 环境）：

```powershell
cd D:\matlab2024b\extern\engines\python
py -3.11 setup.py install
```

2) Python 版本不匹配

- 必须使用 3.11。`py -3.11 --version` 检查；通过 `uv python pin 3.11` 固定版本。

3) 终端输出乱码

- 本机已将 Codex 的 shell 设为 PowerShell 7（UTF‑8），避免乱码。

---

## 打包发布到 GitHub

本仓库提供脚本 `scripts/pack.ps1`：

```powershell
# 在仓库根目录执行
pwsh -NoProfile -File .\scripts\pack.ps1
```

输出：`matlab-mcp.zip`（已排除 `.git`/`.venv`/`output` 等临时文件）。

推送到你自己的 GitHub 仓库：

```powershell
# 1) 在 GitHub 新建一个空仓库（例如 yourname/matlab-mcp）

# 2) 在本地仓库根目录执行：
git remote remove origin 2>$null
git remote add origin https://github.com/<yourname>/<repo>.git
git add .
git commit -m "docs: add Chinese README and pack script"
git push -u origin HEAD:main
```

如需通过 GitHub CLI 创建仓库：

```powershell
gh repo create <yourname>/<repo> --private --source . --remote origin --push
```

---

## 许可证与来源

本仓库基于公开项目进行本地化与脚本补充，以便在 Windows + Codex 环境下更易用。请在对外发布时遵守上游项目的许可证条款。

