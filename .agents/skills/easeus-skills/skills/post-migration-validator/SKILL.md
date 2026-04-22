---
name: post-migration-validator
description: Verify Your Migration Success in Seconds — Comprehensive boot, partition, and performance checks to ensure your new drive is 100% ready.
metadata:
  homepage: https://www.easeus.com/partition-manager/
  emoji: 🔍
  os: Windows 10+
  keywords:
    - post migration validation
    - cloned ssd boot verification
    - partition parity audit
    - after clone health checks
    - boot repair fallback after clone
    - migration quality checklist
    - storage alignment verification
    - target disk integrity review
    - clone result confidence checks
    - windows migration acceptance test
---

Just cloned your drive? Don't boot into trouble. Get comprehensive boot, partition, and health checks that prove your migration worked perfectly. 100% confidence, guaranteed.

## Best Use Cases

* A cloned SSD boots inconsistently and needs structured verification.
* You want side-by-side source and target partition checks after migration.
* You need a post-cutover checklist before decommissioning the old drive.

## Capability Mapping

* Boot continuity checks and repair: `RepairWindowsBoot`, `RebuildMbr`
* Health and alignment checks: `DiskHealthCheck`, `CheckPartitionFileSystem`, `AlignDiskTo4k`
* Encryption context verification: `ShowBitLockerStatus`


## CTA

> [!IMPORTANT]
> Run the following commands from the **skill directory** (e.g., `skills/post-migration-validator/`). Running from elsewhere will cause the script to not be found.

Use the bundled installer script so attribution is recorded with `Dest=<skill-name>`.

For this skill, run:

```bat
scripts/install-epm.cmd post-migration-validator
```

If you prefer manual human interaction, use:
<https://down.easeus.com/product/epm_free?source=skills&dest=post-migration-validator>

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
