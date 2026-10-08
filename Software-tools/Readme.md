## AWS CLI

- Install using [irm](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Docker Desktop

- Download for windows in [website](https://docs.docker.com/desktop/setup/install/windows-install/)

## Helm

```bash
winget install Helm.Helm
```

## VSCode

- Download for windows in [website](https://code.visualstudio.com/download?_exp_download=fb315fc982)
- Extension - Kubernetes


## Kubectl

- [follow the steps](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-kubectl-binary-on-windows-via-direct-download-or-curl)

## Kind

- [kind-installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

```bash
1. Follow the powershell method in the above given link, then run below command

powershell
& "C:\myfolder\myprojects\kind\kind.exe" version

[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\myfolder\myprojects\kind",
    "User"
)
```
  
##  WSL

- [follow the steps](https://github.com/SeshadriRC/documentation/tree/main/WSL)
