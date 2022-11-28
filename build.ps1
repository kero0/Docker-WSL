param(
    # Distro You want to build
    [string]$distro,
    # WSL name
    [string]$wslName,
    # Path to dockerfile
    [string]$dockerfile = ".\$distro.Dockerfile",
    # Path to build context
    [string]$context = ".",
    # Should we remove the container image after build
    [switch]$removeImage
)

$ErrorActionPreference = "Stop"

# cd to the directory of the script
Push-Location $(Split-Path -Parent $MyInvocation.MyCommand.Definition)
# print location
Write-Host "Building $distro from $dockerfile in $(Get-Location)"

# Check if dockerfile exists
if (!(Test-Path $dockerfile)) {
    Write-Error "Dockerfile $dockerfile does not exist"
    exit 1
}
# Check if build context exists
if (!(Test-Path $context)) {
    Write-Error "Build context $context does not exist"
    exit 1
}

# Build the image
docker build -t "docker-wsl-build-$distro" -f "$dockerfile" "$context"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build docker image"
    exit 1
}

# Run the image
docker run --name "docker-wsl-build-$distro" -idt "docker-wsl-build-$distro"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to run docker-wsl-build-$distro"
    exit 1
}

# Export the image
docker export --output "$context\$distro.tar" "docker-wsl-build-$distro"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to export docker-wsl-build-$distro"
    exit 1
}

# Stop the container
docker stop "docker-wsl-build-$distro"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to stop docker-wsl-build-$distro"
    exit 1
}

# Remove the container
docker rm "docker-wsl-build-$distro"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to remove docker-wsl-build-$distro"
    exit 1
}

# Remove the image (if the user wants to)
if ($removeImage) {
    docker rmi "docker-wsl-build-$distro"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to remove docker-wsl-build-$distro"
        exit 1
    }
}

# Import the distro into WSL
wsl --import "$wslName" "$context\Distros\$wslName" "$context\$distro.tar"
