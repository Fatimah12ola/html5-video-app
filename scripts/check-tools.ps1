param()

function Get-ToolVersion($name, $command) {
    $cmd = Get-Command $command -ErrorAction SilentlyContinue
    if ($cmd) {
        try { $ver = & $command --version 2>$null } catch { $ver = 'found' }
        Write-Host "${name}: $ver"
    } else {
        Write-Host "${name}: NOT FOUND"
    }
}

Get-ToolVersion -name 'Node' -command 'node'
Get-ToolVersion -name 'npm' -command 'npm'
Get-ToolVersion -name 'git' -command 'git'
Get-ToolVersion -name 'gh (GitHub CLI)' -command 'gh'
Get-ToolVersion -name 'az (Azure CLI)' -command 'az'
Get-ToolVersion -name 'docker' -command 'docker'

Write-Host "If any tools above are missing, follow these links to install them:"
Write-Host "- Node.js & npm: https://nodejs.org/"
Write-Host "- Git: https://git-scm.com/downloads"
Write-Host "- GitHub CLI: https://cli.github.com/"
Write-Host "- Azure CLI: https://learn.microsoft.com/cli/azure/install-azure-cli"
Write-Host "- Docker: https://docs.docker.com/get-docker/"
