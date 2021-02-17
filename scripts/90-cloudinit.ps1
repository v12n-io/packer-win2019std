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
Start-Process msiexec.exe -ArgumentList "/i C:\$msiFileName /qn /norestart RUN_SERVICE_AS_LOCAL_SYSTEM=1" -Wait

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

# Update configdrive.py (to unmount the ISO file after completion)
# From https://ask.cloudbase.it/question/2939/how-to-umount-cd-drive-after-cloudbase-init-completed/
$filePath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Lib\site-packages\cloudbaseinit\metadata\services\configdrive.py"
$topOfFile = @"
import os
import shutil
import ctypes

"@
$bottomOfFile = @"

    def cleanup(self):
        LOG.debug('Deleting metadata folder: %r', self._mgr.target_path)
        shutil.rmtree(self._mgr.target_path, ignore_errors=True)
        self._metadata_path = None
        drive_letter = os.popen('wmic logicaldisk where VolumeName="OVF ENV" get Caption | findstr /I ":"').read()
        if drive_letter:
            LOG.debug('Eject metadata drive: %s', str(drive_letter).rstrip())
            ctypes.windll.WINMM.mciSendStringW(u"open " + str(drive_letter).rstrip() + " type cdaudio alias d_drive", None, 0, None)
            ctypes.windll.WINMM.mciSendStringW(u"set d_drive door open", None, 0, None)
"@
Set-Content -Path $filePath -Value ($topOfFile + (Get-Content -Path $filePath) + $bottomOfFile)

# Change service startup type
#Set-Service -Name cloudbase-init -StartupType Manual
& sc.exe config cloudbase-init start= delayed-auto

# Tidy up
Remove-Item -Path ($confPath + "cloudbase-init-unattend.conf") -Confirm:$false 
Remove-Item -Path ($confPath + "Unattend.xml") -Confirm:$false 
Remove-Item C:\$msiFileName -Confirm:$false