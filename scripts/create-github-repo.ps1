param(
    [Parameter(Mandatory=$false)]
    [string]$RepoName = $(Split-Path -Leaf (Resolve-Path ..)),
    [Parameter(Mandatory=$false)]
    [ValidateSet('public','private')]
    [string]$Visibility = 'public'
)

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI (gh) not found. Install it: https://cli.github.com/"
    Write-Host "Or create a repo manually at https://github.com/new"
    exit 1
}

# Check authentication
try {
    gh auth status | Out-Null
} catch {
    Write-Host "GitHub CLI is not authenticated. Run 'gh auth login' and try again."
    exit 1
}

if (-not (Test-Path .git)) {
    git init
}

if (-not (git status --porcelain)) {
    Write-Host "No changes to commit. Proceeding with repo creation."
} else {
    git add -A
    git commit -m "Initial commit"
}

$cmd = "gh repo create $RepoName --$Visibility --source . --remote origin --push"
Write-Host "Running: $cmd"
try {
    iex $cmd
    Write-Host "Repo created and pushed: $RepoName"
} catch {
    Write-Host "Failed to create via gh. Create the repo manually and set the remote:"
    Write-Host "git remote add origin https://github.com/<your-username>/$RepoName.git"
    Write-Host "git push -u origin main"
}
