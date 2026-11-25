#!/usr/bin/env bash
set -euo pipefail

# Use a new directory for each test. The disk and firmware state persist between
# the install and boot commands; no physical disks are attached to QEMU.
usage='Usage: run-install-vm.sh create|install STATE_DIR ISO | boot STATE_DIR'
mode=${1:?$usage}
state=${2:?$usage}
case "$mode" in
  create)
    iso=${3:?$usage}
    [[ $# == 3 ]] || { echo "$usage" >&2; exit 2; }
    iso=$(realpath -e -- "$iso")
    [[ -f "$iso" ]] || { echo 'ISO must be a regular file.' >&2; exit 1; }
    mkdir -- "$state"
    state=$(realpath -e -- "$state")
    cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$state/OVMF_VARS.fd"
    qemu-img create -f qcow2 "$state/disk.qcow2" 32G
    ;;
  install|boot)
    if [[ "$mode" == install ]]; then
      [[ $# == 3 ]] || { echo "$usage" >&2; exit 2; }
      iso=$(realpath -e -- "$3")
      [[ -f "$iso" ]] || { echo 'ISO must be a regular file.' >&2; exit 1; }
    else
      [[ $# == 2 ]] || { echo "$usage" >&2; exit 2; }
    fi
    state=$(realpath -e -- "$state")
    [[ -f "$state/disk.qcow2" && -f "$state/OVMF_VARS.fd" ]] || {
      echo 'State directory must contain the VM disk and firmware variables.' >&2; exit 1;
    }
    ;;
  *) echo "$usage" >&2; exit 2 ;;
esac

module_dir="$(dirname -- "$(dirname -- "$(realpath -e -- "$0")")")/../NeurOS-ISO/build/qemu-modules/usr/lib/qemu"
if [[ -z ${QEMU_MODULE_DIR:-} && -d "$module_dir" ]]; then
  export QEMU_MODULE_DIR="$module_dir"
fi
display=VGA
if qemu-system-x86_64 -device help | grep 'name "virtio-vga"' >/dev/null; then
  display=virtio-vga
fi
printf 'Using QEMU display device: %s\n' "$display"
accel=tcg,thread=multi
cpu=max
if [[ -r /dev/kvm && -w /dev/kvm ]]; then accel=kvm; cpu=host; fi
args=(
  -name 'NeurOS Installer Test' -machine q35 -accel "$accel" -cpu "$cpu"
  -smp 4 -m 6144
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd
  -drive "if=pflash,format=raw,file=$state/OVMF_VARS.fd"
  -drive "if=virtio,format=qcow2,file=$state/disk.qcow2"
  -device "$display" -display gtk -device qemu-xhci -device usb-tablet
  -device intel-hda -device hda-duplex
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0
  -serial "file:$state/serial.log"
)
if [[ "$mode" != boot ]]; then args+=(-cdrom "$iso" -boot d); fi
exec qemu-system-x86_64 "${args[@]}"
