param(
    [string]$Destination = "matlab-mcp.zip"
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path $root -Parent

$tmp = Join-Path $env:TEMP ("matlab-mcp-pack-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

try {
    # 使用 robocopy 复制并排除不需要的目录/文件
    $src = $repoRoot
    $dst = $tmp

    $excludeDirs = @('.git', '.venv', 'output', '.idea', '.vscode', '__pycache__')
    $excludeFiles = @('uv.lock', '*.zip')

    $xd = @()
    foreach($d in $excludeDirs){ $xd += @('/XD', $d) }

    $xf = @()
    foreach($f in $excludeFiles){ $xf += @('/XF', $f) }

    robocopy $src $dst /MIR /NFL /NDL /NJH /NJS @xd @xf | Out-Null

    $zipPath = Join-Path $repoRoot $Destination
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Compress-Archive -Path (Join-Path $tmp '*') -DestinationPath $zipPath -Force

    Write-Host "Created: $zipPath"
}
finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
}

