<#
.SYNOPSIS
    Builds the CraftMatch Android APK locally, calculates metadata, and stages it for backend distribution.

.PARAMETER Version
    The version to stamp into the APK (default: 1.0.0).

.PARAMETER BuildType
    The build type to produce: 'release' (default) or 'debug'.
#>
param(
    [string]$Version = "1.0.0",
    [string]$BuildType = "release"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$FrontendDir = Split-Path -Parent $ScriptDir
$BackendDownloadsDir = Join-Path (Split-Path -Parent $FrontendDir) "artisansApp_backend\public\downloads"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  CraftMatch Android APK Builder & Packager               " -ForegroundColor Cyan
Write-Host "  Version: $Version | Build Type: $BuildType              " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Set-Location $FrontendDir

Write-Host "`n[1/4] Fetching Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "`n[2/4] Compiling Android APK ($BuildType)..." -ForegroundColor Yellow
if ($BuildType -eq "debug") {
    flutter build apk --debug --build-name=$Version
    $SourceApk = Join-Path $FrontendDir "build\app\outputs\flutter-apk\app-debug.apk"
} else {
    flutter build apk --release --build-name=$Version
    $SourceApk = Join-Path $FrontendDir "build\app\outputs\flutter-apk\app-release.apk"
}

if (-not (Test-Path $SourceApk)) {
    Write-Error "Build finished but APK was not found at $SourceApk"
}

Write-Host "`n[3/4] Packaging & Staging Distribution Artifacts..." -ForegroundColor Yellow
if (-not (Test-Path $BackendDownloadsDir)) {
    New-Item -ItemType Directory -Force -Path $BackendDownloadsDir | Out-Null
}

$VersionedTarget = Join-Path $BackendDownloadsDir "CraftMatch-v$Version.apk"
$LatestTarget = Join-Path $BackendDownloadsDir "CraftMatch-latest.apk"

Copy-Item -Path $SourceApk -Destination $VersionedTarget -Force
Copy-Item -Path $SourceApk -Destination $LatestTarget -Force

$FileSizeBytes = (Get-Item $LatestTarget).Length
$FileSizeMB = "{0:N1} MB" -f ($FileSizeBytes / 1MB)
$Sha256Hash = (Get-FileHash -Path $LatestTarget -Algorithm SHA256).Hash.ToLower()

Write-Host "`n[4/4] Generating Release Manifest..." -ForegroundColor Yellow
$Manifest = @{
    appName = "CraftMatch"
    latestVersion = $Version
    updatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    links = @(
        @{
            platform = "android"
            label = "Android APK"
            href = "/api/releases/download/android"
            version = $Version
            fileSize = $FileSizeMB
            fileSizeBytes = $FileSizeBytes
            sha256 = $Sha256Hash
            minRequirement = "Android 8.0 or newer"
            available = $true
            external = $false
        },
        @{
            platform = "web"
            label = "Web PWA"
            href = "https://artisans-app-frontend.vercel.app/"
            version = $Version
            minRequirement = "Latest Chrome, Edge, Safari, or Firefox"
            available = $true
            external = $true
        },
        @{
            platform = "ios"
            label = "iPhone"
            href = ""
            version = $Version
            minRequirement = "iOS 15 or newer"
            available = $false
            external = $true
        },
        @{
            platform = "windows"
            label = "Windows"
            href = ""
            version = $Version
            minRequirement = "Windows 10 or newer"
            available = $false
            external = $true
        },
        @{
            platform = "macos"
            label = "macOS"
            href = ""
            version = $Version
            minRequirement = "macOS 12 or newer"
            available = $false
            external = $true
        }
    )
}

$ManifestJson = $Manifest | ConvertTo-Json -Depth 5
$ManifestPath = Join-Path $BackendDownloadsDir "release-manifest.json"
Set-Content -Path $ManifestPath -Value $ManifestJson -Encoding UTF8

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  Build & Packaging Succeeded!                            " -ForegroundColor Green
Write-Host "  Target APK: $LatestTarget ($FileSizeMB)" -ForegroundColor Green
Write-Host "  SHA256:     $Sha256Hash" -ForegroundColor Green
Write-Host "  Manifest:   $ManifestPath" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
