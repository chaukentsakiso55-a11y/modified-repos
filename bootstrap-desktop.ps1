$ErrorActionPreference = "Stop"

$projects = @(
    @{ Name = "ollama"; Url = "https://github.com/ollama/ollama.git"; Branch = "main" },
    @{ Name = "open-webui"; Url = "https://github.com/open-webui/open-webui.git"; Branch = "main" },
    @{ Name = "jan"; Url = "https://github.com/janhq/jan.git"; Branch = "main" },
    @{ Name = "ComfyUI"; Url = "https://github.com/Comfy-Org/ComfyUI.git"; Branch = "master" },
    @{ Name = "anything-llm"; Url = "https://github.com/Mintplex-Labs/anything-llm.git"; Branch = "master" },
    @{ Name = "CyberChef"; Url = "https://github.com/gchq/CyberChef.git"; Branch = "master" },
    @{ Name = "portmaster"; Url = "https://github.com/safing/portmaster.git"; Branch = "development" },
    @{ Name = "PowerToys"; Url = "https://github.com/microsoft/PowerToys.git"; Branch = "main" },
    @{ Name = "Flow.Launcher"; Url = "https://github.com/Flow-Launcher/Flow.Launcher.git"; Branch = "dev" },
    @{ Name = "winutil"; Url = "https://github.com/ChrisTitusTech/winutil.git"; Branch = "main" }
)

New-Item -ItemType Directory -Force -Path "desktop" | Out-Null
$env:GIT_LFS_SKIP_SMUDGE = "1"

foreach ($project in $projects) {
    $destination = Join-Path "desktop" $project.Name

    if (Test-Path $destination) {
        Remove-Item -Recurse -Force $destination
    }

    git clone --depth 1 --single-branch --branch $project.Branch $project.Url $destination

    $upstreamCommit = (git -C $destination rev-parse HEAD).Trim()
    Remove-Item -Recurse -Force (Join-Path $destination ".git")

    $metadata = [ordered]@{
        name = $project.Name
        upstream = $project.Url.Replace(".git", "")
        upstream_branch = $project.Branch
        upstream_commit = $upstreamCommit
        workspace = "EMBER"
        editable = $true
        preserve_upstream_license = $true
    }

    $metadata | ConvertTo-Json | Set-Content -Encoding UTF8 (Join-Path $destination "EMBER_PROJECT.json")
}

git add desktop
git commit -m "Import desktop projects for EMBER modification"
git push origin main
