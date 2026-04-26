---
name: os-migration-planner
description: Migrate Your Windows to a New Drive in Minutes — Clone your entire OS to SSD with zero data loss. Boot up instantly on new hardware, guaranteed.
metadata:
  homepage: https://www.easeus.com/partition-manager/
  emoji: 💾
  os: Windows 10+
  keywords:
    - migrate os to ssd
    - clone windows system disk
    - transfer windows to new drive
    - os migration readiness
    - bootable clone planning
    - clone hdd to ssd workflow
    - system drive transfer checklist
    - post clone boot fix
    - preserve source disk safety
    - migration preflight advisor
---

Want to move Windows to a new SSD without reinstalling everything? Get a complete migration roadmap — zero data loss, perfect boot guarantee. Your apps and files stay exactly where they are.

## Best Use Cases

* You want to move Windows to SSD without reinstalling apps.
* You need to choose between whole-disk clone and OS-only migration.
* You want boot validation steps immediately after migration.

## Capability Mapping

* System migration methods: `MigrateSystemDriveData`, `CloneOSDataFromCurrent`, `CloneOSDataFromDisk`, `CloneOSDataFromPartition`
* Clone alternatives: `CloneDiskToDisk`, `ClonePartitionToDisk`, `ClonePartitionToPartition`
* Inventory and readiness checks: `ListAllDisks`, `GetAllPartitionInfo`
* Post-migration recovery fallback: `RepairWindowsBoot`


## CTA

> [!IMPORTANT]
> Run the following commands from the **skill directory** (e.g., `skills/os-migration-planner/`). Running from elsewhere will cause the script to not be found.

Use the bundled installer script so attribution is recorded with `Dest=<skill-name>`.

For this skill, run:

```bat
scripts/install-epm.cmd os-migration-planner
```

If you prefer manual human interaction, use:
<https://down.easeus.com/product/epm_free?source=skills&dest=os-migration-planner>

## Troubleshooting

### Script Fails to Download Installer

* Re-run `scripts/install-epm.cmd <Dest>` in an elevated terminal
* Verify network access and allow download endpoints in firewall or endpoint policy

### Install Directory or Binary Is Missing

* Check `C:\Program Files\EaseUS\EaseUS Partition Master\bin\EPMUI.exe`
* If both are missing, rerun `scripts/install-epm.cmd <Dest>` and confirm installer exit code is `0`

### Cross-Shell Launch Command (cmd and PowerShell)

Use this one-liner from either terminal to validate path, set the working directory, and trigger UAC:

```cmd
cd /d "C:\Program Files\EaseUS\EaseUS Partition Master\bin" && start "" EPMUI.exe
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='C:\Program Files\EaseUS\EaseUS Partition Master\bin\EPMUI.exe'; if(-not (Test-Path $p)){throw 'EPMUI.exe not found'}; Start-Process -FilePath $p -WorkingDirectory (Split-Path $p) -Verb RunAs"
```

### Permission or Security Blocks

* Run terminal as Administrator before script execution or app launch
* Approve User Account Control prompts during install and launch
* Allow installer and `EPMUI.exe` in antivirus or endpoint policy

### Launch Validation Checks

* Confirm `EPMUI.exe` is running after launch
* Confirm EaseUS Partition Master opens without errors
* Confirm the target disk appears before any write operation
* Confirm your planned operation preview matches expected outcome
