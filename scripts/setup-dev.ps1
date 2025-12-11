param(
    [switch]$SkipDependencies
)

$projectRoot = Resolve-Path -Path ((Split-Path -Parent $MyInvocation.MyCommand.Path) + "\..")
Write-Host "Project root: $projectRoot"

# ensure uploads and data directories exist
$uploads = Join-Path $projectRoot 'uploads'
$data = Join-Path $projectRoot 'data'
if (-not (Test-Path $uploads)) { New-Item -ItemType Directory -Path $uploads | Out-Null }
if (-not (Test-Path $data)) { New-Item -ItemType Directory -Path $data | Out-Null }

# ensure a videos.json exists
$videosFile = Join-Path $data 'videos.json'
if (-not (Test-Path $videosFile)) { '[]' | Out-File -FilePath $videosFile -Encoding utf8 }

# copy .env.example to .env if missing
$envFile = Join-Path $projectRoot '.env'
$envExample = Join-Path $projectRoot '.env.example'
if (-not (Test-Path $envFile) -and (Test-Path $envExample)) { Copy-Item -Path $envExample -Destination $envFile }

Write-Host "Created uploads and data folders (if missing) and ensured data/videos.json exists."

# If npm exists and dependencies not skipped, install
if ($SkipDependencies) {
    Write-Host "Skipping dependency install (SkipDependencies set)."
    return
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "npm found - installing dependencies..."
    npm install
    Write-Host "Dependencies installed."
} else {
    Write-Host "npm is not installed or not visible in PATH."
    Write-Host "Please install Node.js and npm from https://nodejs.org or use winget/choco/nvm."
}

Write-Host "Setup complete. Run 'npm run dev' to start the app."
