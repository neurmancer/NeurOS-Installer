#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/.." && pwd)
out=${1:-"$root/build/package"}
mkdir -p "$out"
out=$(realpath "$out")
tar -czf "$out/neuros-installer-0.1.0.tar.gz" --transform='s,^,neuros-installer-0.1.0/,' -C "$root" CMakeLists.txt LICENSE src scripts packaging/neuros-installer.desktop
sum=$(sha256sum "$out/neuros-installer-0.1.0.tar.gz")
sed "s/REPLACE_CHECKSUM/${sum%% *}/" "$root/packaging/PKGBUILD" > "$out/PKGBUILD"
printf 'Package source ready: %s\n' "$out"
