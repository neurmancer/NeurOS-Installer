"""Remove live-only configuration before creating the target user."""
from pathlib import Path
import subprocess
import libcalamares

def pretty_name():
    return "Disconnecting the live environment"

def run():
    root = Path(libcalamares.globalstorage.value("rootMountPoint") or "/").resolve()
    if root == Path("/") or not (root / "etc/os-release").is_file():
        return ("Invalid target", "A mounted target system is required.")
    paths = [
        "etc/sudoers.d/10-neuros-live", "etc/sddm.conf.d/10-neuros-live.conf",
        "etc/mkinitcpio.conf.d/archiso.conf", "etc/systemd/system/systemd-firstboot.service",
        "etc/systemd/system/pacman-init.service", "etc/systemd/system/etc-pacman.d-gnupg.mount",
        "etc/systemd/system/multi-user.target.wants/pacman-init.service",
        "etc/systemd/system/multi-user.target.wants/etc-pacman.d-gnupg.mount",
        "usr/local/bin/neuros-live-session", "usr/share/wayland-sessions/neuros-live.desktop",
    ]
    for name in paths:
        (root / name).unlink(missing_ok=True)
    # This runs before the users job, so the chosen login may also be 'neuro'.
    result = subprocess.run(["chroot", str(root), "getent", "passwd", "neuro"], capture_output=True)
    if result.returncode == 0:
        subprocess.run(["chroot", str(root), "userdel", "--force", "--remove", "neuro"], check=True)
    (root / "etc/mkinitcpio.d/linux-neuros.preset").write_text(
        'ALL_kver="/boot/vmlinuz-linux-neuros"\nPRESETS=(default)\ndefault_image="/boot/initramfs-linux-neuros.img"\n')
    subprocess.run(["chroot", str(root), "passwd", "--lock", "root"], check=True)
    return None
