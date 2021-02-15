# Install and configure Cloudbase-Init
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

$msiLocation = "https://cloudbase.it/downloads"
$msiFileName = "CloudbaseInitSetup_Stable_x64.msi"

# Download MSI file
Invoke-WebRequest -Uri ($msiLocation + "/" + $msiFileName) -OutFile C:\$msiFileName
Unblock-File -Path C:\$msiFileName

# Install Cloudbase-Init
Start-Process msiexec.exe -ArgumentList "/i C:\$msiFileName /qn /norestart"

# Overwrite cloudbaseinit.conf
$confFile = "cloudbase-init.conf"
$confPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\"
$confContent = @"
[DEFAULT]
config_drive_cdrom=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
metadata_services=cloudbaseinit.metadata.services.ovfservice.OvfService
plugins=cloudbaseinit.plugins.common.userdata.UserDataPlugin
"@
New-Item -Path $confPath -Name $confFile -ItemType File -Force -Value $confContent

# Delete install MSI file
Remove-Item C:\$msiFileName -Confirm:$false