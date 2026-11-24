param(
    [Parameter(Mandatory = $true)][string]$MemberFile,
    [string]$Summary = "",
    [string]$Tested = "mvn test PASS",
    [string]$Notes = "-"
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$progressPath = Join-Path (Join-Path $repoRoot "docs\progress") $MemberFile
if (-not (Test-Path -LiteralPath $progressPath)) {
    throw "Không tìm thấy file tiến độ: $progressPath. Hãy truyền đúng tên file trong docs\progress (VD: Đặng_Trần_Thiện.md)."
}

Push-Location $repoRoot
try {
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
    $commit = (git rev-parse --short HEAD).Trim()
    if (-not $Summary) {
        $Summary = (git log -1 --pretty=%s).Trim()
    }
} finally {
    Pop-Location
}

$today = (Get-Date).ToString("yyyy-MM-dd")
$safeSummary = ($Summary -replace "\|", "/").Trim()
$safeTested = ($Tested -replace "\|", "/").Trim()
$safeNotes = ($Notes -replace "\|", "/").Trim()
$row = "| $today | ``$branch`` | ``$commit`` | $safeSummary | $safeTested | $safeNotes |"

$content = [System.IO.File]::ReadAllText($progressPath, [System.Text.UTF8Encoding]::new($false))
if ($content -match [regex]::Escape("| ``$commit`` |")) {
    Write-Output "Commit $commit da duoc ghi trong $MemberFile truoc do."
    exit 0
}
if (-not $content.EndsWith("`n")) { $content += "`r`n" }
$content += $row + "`r`n"
[System.IO.File]::WriteAllText($progressPath, $content, [System.Text.UTF8Encoding]::new($false))
Write-Host "Da ghi commit $commit vao docs\progress\$MemberFile" -ForegroundColor Green
