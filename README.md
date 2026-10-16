# NeurOS Installer

A native Qt 6 / QML installer interface inspired by the NSD concept sheets:
near-black panels, violet geometry, mint accents, clipped buttons and a slowly
rotating core. No browser or web server is involved.

## Run

On Arch, build dependencies are `cmake`, `ninja`, `gcc`, `qt6-base`,
`qt6-declarative`; runtime SVG artwork also uses `qt6-svg`. Install
`ttf-dejavu` for the explicit DejaVu Sans and DejaVu Sans Mono UI fonts. Disk discovery uses
`lsblk` from `util-linux`. The original concept art remains untouched.

```sh
bash scripts/preview.sh
```

The standalone GUI is an **interactive preview**, not a disk installer. It runs
as a normal user. It never invokes sudo, partitions, formats, mounts, installs
packages, modifies host configuration or changes the active keyboard layout.

The six pages cover welcome, location, keyboard, storage, identity and review.
Choices survive back/forward navigation. Storage uses read-only `lsblk` discovery;
no disks are preselected. Account validation gates progression. Alt+Left/Right
navigate; Tab reaches controls; Escape opens the exit dialog. Motion can be
turned off. Selected locale/layout choices are plan data, not live translations.

The Review page exports an allowlisted JSON plan through a save dialog. Passwords
are deliberately excluded. They live only in the preview process and are discarded
when it closes; this is not a secure credential handoff implementation. There is
no simulated installation or false success screen. The Install button stays
disabled until the installation backend exists.

## Build, inspect and install the preview

```sh
cmake -S . -B build -G Ninja
cmake --build build
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  build/neuros-installer --screenshots build/screenshots
# Optional staging, without writing into the host system:
DESTDIR="$PWD/build/stage" cmake --install build --prefix /usr
```

Screenshot mode exercises empty-account, valid-account and mismatched-password
validation and captures all six screens, then exits. Captured review pages can
show an incomplete plan; screenshots are visual checks, not installation evidence.

## Calamares assets

`src/branding/NeurOS/` supplies a real `branding.desc`, a two-slide QML slideshow,
an SVG mark, the supplied purple/green wordmark, and a widget stylesheet.
`stylesheet.qss` is the name Calamares discovers; `style.qss` is retained from the
boilerplate as the editable source. Keep them synchronized when changing styles.

The branding selects native Calamares widget navigation/sidebar. The existing
`calamares-nav.qml` and `calamares-sidebar.qml` are visual studies only; they are
not falsely wired to an undocumented Calamares navigation API. The standalone
preview is not a Calamares module and does not launch Calamares.

## Actual installation (development)

The production direction is a separate Calamares frontend. The standalone QML
preview remains a design prototype; its exported JSON is never executed or
imported into Calamares. Launch **Install NeurOS** from the live image to use the
branded Calamares wizard with its own validated locale, keyboard, partition,
account, summary, progress and error pages.

`src/etc/calamares/settings.conf` defines the offline sequence. Installation
requires UEFI, Secure Boot disabled, an ext4 root, and a FAT32 ESP at `/boot`.
Encryption and manual partitioning are disabled in this initial profile.
The complete live filesystem supplies the desktop, Axon and Radioport; no
network package downloads are required during installation.

The launcher snapshots disk identity. `neurospreflight` compares it immediately
before partition jobs. `neuroscleanup` removes live-only settings before the
Calamares users job creates the selected account. `neurosboot` generates the
matching initramfs and stages systemd-boot → NeurOS → Linux. Cancel is available
before installation, disabled during disk writes, and errors are reported by
the actual job queue. A failed install is not automatically rolled back.

This configuration is **under validation**, not a completed release. Read
[STEPS.md](STEPS.md) for evidence and remaining checks. Do not invoke the config
on a development host. The supported launcher refuses non-live systems.

Build the package:

```sh
bash scripts/export-package.sh
cd build/package
makepkg -s
```

Supply the resulting archive to NeurOS-Packages/packages/neuros-installer.
NeurOS-ISO's prepare script resolves it together with Calamares and its dependencies.
Original code is MIT, as in LICENSE. Concept artwork retains its existing rights.
