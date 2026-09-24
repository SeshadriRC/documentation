```bash
Open PowerShell as Administrator

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

C:\Windows\Sysnative\bcdedit.exe /set hypervisorlaunchtype auto

Restart your computer

Press Win + R.

Type cmd and press Enter

Automatically wsl will install 

wsl --version
```
