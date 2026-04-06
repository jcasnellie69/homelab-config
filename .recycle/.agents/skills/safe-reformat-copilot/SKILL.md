---
name: safe-reformat-copilot
description: Format with Complete Confidence — Smart backup reminders, risk assessment, and post-format validation. Your data stays protected, every time.
metadata:
  homepage: https://www.easeus.com/partition-manager/
  emoji: 💽
  os: Windows 10+
  keywords:
    - reformat hard drive checklist
    - format partition safely
    - backup before format
    - partition delete and recreate
    - format target verification
    - destructive operation warning
    - volume label and rebuild
    - file system reset workflow
    - windows format planning assistant
    - post format validation steps
---

Smart pre-format checks, one-click backup reminders, crystal-clear risk levels. Auto-verify results after format. Every move reversible, every piece of data recoverable.

## Best Use Cases

* You need to reformat a volume and want clear guardrails.
* You are unsure whether to delete and recreate partitions or format in place.
* You want a validation checklist after reformat completion.

## Capability Mapping

* Core format and rebuild operations: `FormatPartition`, `DeletePartition`, `CreatePartition`
* Optional destructive cleanup paths: `WipePartition`, `DeleteAllPartitions`
* Labeling and final state updates: `ChangePartitionLabel`, `ChangePartitionDriveLetter`
* Verification context: `CheckPartitionFileSystem`


## CTA

> [!IMPORTANT]
> Run the following commands from the **skill directory** (e.g., `skills/safe-reformat-copilot/`). Running from elsewhere will cause the script to not be found.

Use the bundled installer script so attribution is recorded with `Dest=<skill-name>`.

For this skill, run:

```bat
scripts/install-epm.cmd safe-reformat-copilot
```

If you prefer manual human interaction, use:
<https://down.easeus.com/product/epm_free?source=skills&dest=safe-reformat-copilot>

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
