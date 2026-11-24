param(
    [string]$DbHost = "localhost",
    [int]$Port = 5432,
    [string]$DbName = "nhom12_dev",
    [string]$User = "postgres",
    [switch]$RunSqlDirect,
    [switch]$RunVerify
)

$ErrorActionPreference = 'Stop'

function Resolve-PgTool([string]$toolName) {
    $cmd = Get-Command $toolName -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    # Tự động phát hiện dịch vụ PostgreSQL đang cài trên Windows (kể cả ổ D:\ hoặc đường dẫn tùy chỉnh)
    try {
        $pgServices = Get-CimInstance Win32_Service -Filter "Name LIKE 'postgresql%'" -ErrorAction SilentlyContinue
        foreach ($svc in $pgServices) {
            if ($svc.PathName -match '"?([^"]+pg_ctl\.exe)"?') {
                $binDir = Split-Path -Parent $Matches[1]
                $candidate = Join-Path $binDir "$toolName.exe"
                if (Test-Path -LiteralPath $candidate) { return $candidate }
            }
        }
    } catch { }

    $fallbackDirs = @(
        "C:\Program Files\PostgreSQL\18\bin",
        "C:\Program Files\PostgreSQL\17\bin",
        "C:\Program Files\PostgreSQL\16\bin",
        "C:\Program Files\PostgreSQL\15\bin",
        "D:\PostgreSQL\17\bin",
        "D:\postqreSQL\bin"
    )
    foreach ($dir in $fallbackDirs) {
        $candidate = Join-Path $dir "$toolName.exe"
        if (Test-Path -LiteralPath $candidate) { return $candidate }
    }
    throw "Không tìm thấy '$toolName'. Hãy cài đặt PostgreSQL 17 (https://www.postgresql.org/download/windows/) hoặc thêm thư mục ...\PostgreSQL\17\bin vào PATH."
}

$psql = Resolve-PgTool "psql"
Write-Host "Su dung psql: $psql" -ForegroundColor Cyan

if (-not $env:PGPASSWORD) {
    $sec = Read-Host "Nhap mat khau PostgreSQL cho user '$User'" -AsSecureString
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
    try {
        $env:PGPASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

$exists = & $psql -X -tAc "SELECT 1 FROM pg_database WHERE datname = '$DbName'" -U $User -h $DbHost -p $Port -d postgres
if ($LASTEXITCODE -ne 0) { throw "Khong the ket noi PostgreSQL tai ${DbHost}:${Port}." }

if ($exists.Trim() -ne "1") {
    Write-Host "Dang tao database '$DbName' (UTF-8)..." -ForegroundColor Yellow
    & $psql -X -v ON_ERROR_STOP=1 -U $User -h $DbHost -p $Port -d postgres -c "CREATE DATABASE $DbName WITH ENCODING 'UTF8';"
    if ($LASTEXITCODE -ne 0) { throw "Tao database that bai." }
    Write-Host "Da tao database '$DbName'." -ForegroundColor Green
} else {
    Write-Host "Database '$DbName' da ton tai." -ForegroundColor Green
}

if ($RunSqlDirect) {
    $repoSqlDir = Join-Path $PSScriptRoot "..\docs\database"
    $legacySqlDir = Join-Path $PSScriptRoot "..\..\file đặc tả hệ thống mới nhất\PostgreSQL"
    $sqlDir = if (Test-Path -LiteralPath (Join-Path $repoSqlDir "001_schema.sql")) { $repoSqlDir } else { $legacySqlDir }
    $scripts = @("001_schema.sql", "002_publish_prescription.sql", "003_seed_dev.sql")
    if ($RunVerify) { $scripts += "090_verify.sql" }
    foreach ($s in $scripts) {
        $fp = Join-Path $sqlDir $s
        Write-Host "Đang chạy $s..." -ForegroundColor Cyan
        & $psql -X -v ON_ERROR_STOP=1 -U $User -h $DbHost -p $Port -d $DbName -f $fp
        if ($LASTEXITCODE -ne 0) { throw "Lỗi khi chạy $s." }
    }
    Write-Host "Đã nạp schema + seed PostgreSQL thành công." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Database '$DbName' da san sang cho Spring Boot + Flyway." -ForegroundColor Green
    Write-Host "Buoc tiep theo:" -ForegroundColor White
    Write-Host "  1. Tao file .env (hoac dat bien DATABASE_PASSWORD) tu .env.example"
    Write-Host "  2. Chay backend: cd backend; mvn spring-boot:run"
    Write-Host "Flyway se tu dong chay V1__init_schema.sql, V2__publish_prescription_and_views.sql va V3__dev_seed.sql."
}
