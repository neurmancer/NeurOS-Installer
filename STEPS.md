# Installer continuation

## Implemented and checked

- Native QML preview: six pages, dark selectors, keyboard navigation and validation.
- Host packaged UI checks: all 11 font/navigation/validation checks passed.
- Calamares separate frontend architecture and documented backend storage contract.
- Real Calamares locale, keyboard, users, summary and progress views configured.
- Offline filesystem deployment, live cleanup, initramfs and custom bootloader jobs.
- Pre-partition whole-disk identity comparison; explicit confirmation enabled.
- Cancellation disabled during execution; actual backend errors remain visible.
- Installer package builds; ISO dependency resolution passes with 19 local packages.
- Three backend tests pass: host-root rejection, scoped cleanup, disk replacement.

## Validation still required — do not mark complete prematurely

1. Finish live ISO UI checks and inspect 100%/150% software-rendered screenshots.
   Guest setup required trusted keyring initialization and expanding its 256 MiB
   RAM overlay. Host checks passed; live checks are still running.
2. Verify every module loads in the branded Calamares wizard and the launcher
   works from the actual live desktop. Prototype JSON remains non-executable;
   the prototype itself is not connected to Calamares GlobalStorage.
3. Complete a disposable-disk install, inspect target account/security settings,
   remove the ISO and verify independent boot through NeurOS into the desktop.
4. Rebuild the final ISO with the latest installer package after guest fixes.

## Deliberate initial limitations

- UEFI, Secure Boot disabled, ext4 root, FAT32 ESP at /boot, offline install.
- Encryption, Btrfs and online package selection need separate boot validation.
- The standalone QML prototype remains a preview. Calamares owns real installation.
- Opt-in kernel-update boot-set refresh/retention hooks exist in bootloader
  package revision -2; they need the documented upgrade and recovery tests.

Do not run this development configuration on the host. Use the live-only launcher
and a disposable QEMU disk for validation. Current build artifacts are development
candidates, not a claim that all seven original milestones are complete.
