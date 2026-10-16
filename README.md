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

CMake stages branding under `share/neuros-installer/branding`, deliberately outside
Calamares's active configuration. No production `settings.conf` is provided yet.
The established `src/etc/calamares` and `src/modules` directories are reserved for
that integration. See [STEPS.md](STEPS.md) for the remaining work.

Original code is MIT, as in LICENSE. Concept artwork remains attributed to its
existing source; adding it here does not change third-party rights.
