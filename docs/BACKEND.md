# Backend contract

Calamares 3.4.2 owns the executable install plan. The preview JSON schema remains
non-executable and carries no passwords. Native Calamares views supply translated
locale/layout inventories, account validation, passwords and partition operations.
No preview value is interpolated into a shell command.

Custom jobs read only these GlobalStorage fields:

| Key | Producer | Consumer |
| --- | --- | --- |
| rootMountPoint | mount | neuroscleanup, neurosboot |

The built-in partition module supplies `partitions` to mount/fstab. Users and
locale/keyboard consume their own built-in storage contract. NeurOS does not
copy account passwords into files, environment variables or argv; Calamares
handles credential application within its users job. Do not run with debug
logging when entering real credentials.

The preflight job compares all whole disks against the launch-time snapshot
(path, major/minor, size, model, serial, WWN, read-only flag). It aborts when
storage changes. This narrows, but cannot eliminate, hot-unplug races after the
check. Review the actual Calamares summary and confirmation before installation.

Initial scope: offline UEFI, Secure Boot off, ext4, unencrypted FAT32 ESP at
/boot. Full encryption, Btrfs and online selection need separate implementation
and boot tests. The QML prototype is not a substitute for the Calamares views.
