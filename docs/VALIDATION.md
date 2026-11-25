# Installer validation and beta checklist

The standalone Qt/QML application is a design preview. Its exported plan is not
executed. The separate Calamares configuration owns the installation workflow;
it is development software until its complete path has been tested.

## Recorded evidence

- Eleven host preview checks passed for fonts, navigation and validation. These
  do not validate Calamares or an installation.
- The installer package and an ISO dependency set have been built locally. The
  ISO preparation manifest most recently recorded installer `0.1.0-5` from a
  temporary path; the package directory contains earlier local archives. Preserve
  and verify the actual inputs when making a new image.
- Three backend checks are recorded as passing: host-root rejection, scoped
  cleanup and disk replacement detection. These are not end-to-end disk tests.
- Newer development ISO files exist, but no completed install and independent
  boot from them is recorded here.

## Before the first beta attempt

1. Complete the planned kernel configuration and validate the newly built kernel.
   Rebuild the installer package from the current checkout, put the resulting
   archive in the package collection, and rebuild the ISO with recorded inputs.
2. Boot the actual image and check that the live desktop and installer launcher
   work. Verify the branded localeq and keyboardq modules and the remaining
   Calamares pages, including keyboard navigation and readable scaling.
3. Install to a new disposable QEMU disk. Inspect the resulting user account,
   sudo configuration, live-only cleanup, filesystems and boot setup. Capture
   errors and logs without including passwords or other sensitive data.
4. Shut down, detach the ISO, and boot the virtual disk independently. Verify
   login, the desktop, networking, audio, applications, reboot and shutdown.
   Record the image hash, package versions, VM settings and results.
5. Implement and test kernel-update boot-set refresh and retention. Validate
   update delivery, physical hardware and other release gates described in the
   [ISO beta checklist](../../NeurOS-ISO/docs/BETA.md).

The current initial profile targets UEFI with Secure Boot disabled, an ext4 root
and FAT32 ESP at `/boot`. Encryption, Btrfs and manual partitioning are not
supported by this profile. A failed installation is not automatically rolled
back. Use the live-only launcher and a disposable VM disk; do not run the
configuration on the development host.

## Disposable VM commands

From this repository, replace the example ISO with the verified candidate. The
state directory must not already exist. The script attaches only its new virtual
disk, and retains that disk and its firmware variables for the later boot.

```sh
bash scripts/run-install-vm.sh create build/beta-vm ../NeurOS-ISO/out/CANDIDATE.iso
bash scripts/run-install-vm.sh install build/beta-vm ../NeurOS-ISO/out/CANDIDATE.iso
# After installation and shutdown, boot without the ISO:
bash scripts/run-install-vm.sh boot build/beta-vm
```

The launcher requires QEMU, OVMF and a working graphical display; it uses KVM
when available and otherwise software emulation. These commands are for a local
test, not evidence that the current image has passed.
