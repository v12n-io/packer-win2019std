# packer-win2019std
Packer build for Windows Server 2019 Std

This repository contains a Packer build for Windows Server 2019 Standard on a vSphere platform.
## Structure

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

The Packer template itself is in the root of the repository and is named "win2019std.json". This file is used by Packer to build / provision the template in to vSphere.

The Autounattend.xml file is a standard file used during unattended installations of Windows OSs. This particular file is configured specifically for the following customisations:
