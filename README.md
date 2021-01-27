# packer-win2019std
Packer build for Windows Server 2019 Std

This repository contains a Packer build for Windows Server 2019 Standard on a vSphere platform.
## Structure

```
├── README.md
├── config
│   └── Autounattend.xml
├── scripts
│   ├── 00-vmtools64.cmd
│   ├── 01-initialise.ps1
│   ├── 03-systemsettings.ps1
│   ├── 04-tlsconfig.ps1
│   ├── 10-createuser.ps1
│   ├── 40-ssltrust.ps1
│   ├── 60-openssh.ps1
│   ├── 80-ansible.ps1
│   └── 95-enablerdp.ps1
├── vars
│   ├── var-common.json
│   └── var-win2019std.json
└── win2019std.json
```

The Packer template itself is in the root of the repository and is named "win2019std.json". This file is used by Packer to build / provision the template in to vSphere.

The Autounattend.xml file is a standard file used during unattended installations of Windows OSs. This particular file is configured specifically for the following customisations:
* Regional settings are configured for UK / GB
* A placeholder string "REPLACEWITHWIN2019STDLIC" is used instead of an actual license key
* A placeholder string "REPLACEWITHWINDOWSPASSWORD" is used instead of an password
* The installation is configured to look for storage drivers in the path E:\Program Files\VMware\VMware Tools\Drivers\pvscsi\Win8\amd64. Per the Packer template file, this is an ISO image mounted from the ESXi host that contains VMware Tools. Thus the template can be built using the paravirtualized SCSI disk controller, which Windows doesn't have a native driver for. This does have the drawback that the template ends up with 2 CD / DVD drives but avoids breaching any licensing conditions by publishing a proprietary driver on GitHub!
* Along with the Autounattend.xml file, two other files are placed in a floppy disk image.
  * 00-vmtools64.cmd - this script silently installs the full VMware Tools application from the attached ISO image.
  * 01-initialise.ps1 - this script prepares WinRM so that further scripts can be executed later in the build.

The scripts in the scripts folder undertake a number of customisation operations. There is no environment specific information held in any of the scripts. Consequently, they need editing before they are used or customisation is possible by replacing pieces of placholder text.

The vars folder contains JSON files that are used by the Packer template to customise the build. Most options are configured from within these two files and some of the options rely on environment variables to populates the values.

## Environment Variables
The two files in the vars folder contain a number of options that are evaluated and populated at runtime by Packer using values set in environment variables. The environment variables that are used can be set per the following examples:

```
export VSPHEREVCENTER='vcenter_server_fqdn'
export VSPHEREUSER='vsphere_user'
export VSPHEREPASS='vsphere_password'
export VSPHEREDATACENTER='vsphere_datacenter'
export VSPHERECLUSTER='vsphere_cluster'
export VSPHEREDATASTORE='vm_datastore'
export VSPHERENETWORK='portgroupname'
export VSPHEREISODS='iso_datastore'
export LINUXUSER='nonrootuser'
export LINUXPASS='C0mplexP@ssword'
export WINDOWSPASS='C0mplexP@ssword'
export BUILDVERSION='<insertdate>'
export BUILDREPO='https://github.com/v12n-io/packer-win2019std'
export BUILDBRANCH='main'
export HTTPSERVER='http://<webserver>'
```

## Placeholders
To make the various scripts more portable, key configuration items are represented by placeholder text strings (such as those in the Autounattend.xml file above). These can easily be replaced with a smattering of grep and sed.

```
## Replace Windows licenses
# Windows 2019 Standard
grep -rl 'REPLACEWITHWIN2019STDLIC' | xargs sed -i 's/REPLACEWITHWIN2019STDLIC/<licensekey>/g'
# Windows 2016 Standard
grep -rl 'REPLACEWITHWIN2016STDLIC' | xargs sed -i 's/REPLACEWITHWIN2016STDLIC/<licensekey>/g'

## Replace Windows Administrator password
grep -rl 'REPLACEWITHWINDOWSPASSWORD' | xargs sed -i 's/REPLACEWITHWINDOWSPASSWORD/<password>/g'

## Replace Linux root password
grep -rl 'REPLACEWITHROOTPASSWORD' | xargs sed -i 's/REPLACEWITHROOTPASSWORD/<password>/g'

## Replace user credentials
grep -rl 'REPLACEWITHLINUXUSERNAME' | xargs sed -i 's/REPLACEWITHLINUXUSERNAME/<nonrootuser>/g'
grep -rl 'REPLACEWITHLINUXUSERPASS' | xargs sed -i 's/REPLACEWITHLINUXUSERPASS/<password>/g'
grep -rl 'REPLACEWITHWINDOWSUSER' | xargs sed -i 's/REPLACEWITHWINDOWSUSER/Administrator/g'
grep -rl 'REPLACEWITHWINDOWSPASS' | xargs sed -i 's/REPLACEWITHWINDOWSPASS/<password>/g'

## Replace Ansible user name and key
grep -rl 'REPLACEWITHANSIBLEUSERNAME' | xargs sed -i 's/REPLACEWITHANSIBLEUSERNAME/<ansible_user>/g'
grep -rl 'REPLACEWITHANSIBLEUSERKEY' | xargs sed -i 's|REPLACEWITHANSIBLEUSERKEY|<ansible_ssh_key>|g'

## Replace PKI server
grep -rl 'REPLACEWITHPKISERVER' | xargs sed -i 's/REPLACEWITHPKISERVER/<pki_server_fqdn>/g'

## Build Version
grep -rl 'REPLACEWITHBUILDVERSION' | xargs sed -i 's/REPLACEWITHBUILDVERSION/$BUILDVERSION/g'
```

## Executing Packer
Assuming that you've download Packer itself (https://www.packer.io/downloads), and the Windows Update provisioner (https://github.com/rgl/packer-provisioner-windows-update/releases) and that they're both located alongside the template JSON file, then running the build becomes as simple as:

```
packer validate -var-file="vars/var-common.json" -var-file="var-win2019std.json" win2019std.json
```

This doesn't build the template but it does validate that everything is as it should be. There should be no errors returned.

```
packer build -var-file="vars/var-common.json" -var-file="var-win2019std.json" win2019std.json
```

Execution time will vary depending on a number of factors such as how current the Windows ISO image is and how many updates are needed.