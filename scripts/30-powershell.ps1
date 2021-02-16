# Install PowerShell Core
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

$msiLocation = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.2/"
$msiFileName = "PowerShell-7.1.2-win-x64.msi"

# Download MSI file
Invoke-WebRequest -Uri ($msiLocation + "/" + $msiFileName) -OutFile C:\$msiFileName
Unblock-File -Path C:\$msiFileName

# Install PowerShell Core
Start-Process msiexec.exe -ArgumentList "/package C:\$msiFileName /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1" -Wait

# Tidy up
Remove-Item C:\$msiFileName -Confirm:$false