# Docker WSL

This is a repository of Dockerfiles that I use to build the base of my WSL distros.
The bulk of the work is done by the *.Dockerfile files.

## Usage

Prerequisites:
  - [Docker](https://www.docker.com/)
  - [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)

Distros:
  - Archlinux
    ```powershell
    .\build.ps1 -distro myarch -wslName archlinux -context . -removeImage
    ```
