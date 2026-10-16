"""Install a direct NeurOS boot set on the mounted target ESP."""
from pathlib import Path
import re
import subprocess
import libcalamares

def pretty_name():
    return "Wiring the NeurOS boot sequence"

def run():
    root = Path(libcalamares.globalstorage.value("rootMountPoint") or "/").resolve()
    if root == Path("/") or not (root / "etc/fstab").is_file():
        return ("Invalid target", "A mounted target with fstab is required.")
    def call(*args):
        return subprocess.check_output(list(args), text=True).strip()
    esp = root / "boot"
    if call("findmnt", "-n", "-o", "FSTYPE", "--mountpoint", str(esp)) != "vfat":
        return ("Invalid boot partition", "NeurOS requires a FAT32 ESP mounted at /boot.")
    uuid = call("findmnt", "-n", "-o", "UUID", "--mountpoint", str(root))
    if not re.fullmatch(r"[a-fA-F0-9-]+", uuid):
        return ("Invalid root UUID", "Could not identify the target root filesystem.")
    def target(*args):
        subprocess.run(["chroot", str(root), *args], check=True)
    kernels = list((root / "usr/lib/modules").glob("*/vmlinuz"))
    if len(kernels) != 1:
        return ("Ambiguous kernel", "Exactly one installed kernel is required for this development profile.")
    import shutil
    shutil.copyfile(kernels[0], esp / "vmlinuz-linux-neuros")
    (root / "etc/kernel").mkdir(exist_ok=True)
    (root / "etc/kernel/cmdline").write_text(f"root=UUID={uuid} rw rootfstype=ext4 quiet\n")
    target("mkinitcpio", "-p", "linux-neuros")
    target("bootctl", "--esp-path=/boot", "--no-variables", "install")
    loader = esp / "EFI/NeurOS"
    loader.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(root / "usr/lib/neuros-bootloader/neuros.efi", loader / "neuros.efi")
    target("/usr/lib/neuros-bootloader/neuros-update-linux", "/" + str(kernels[0].relative_to(root)),
           "/etc/kernel/cmdline", "/boot/initramfs-linux-neuros.img", "/boot/EFI/NeurOS")
    (esp / "loader/entries").mkdir(parents=True, exist_ok=True)
    (esp / "loader/entries/neuros.conf").write_text("title NeurOS\nefi /EFI/NeurOS/neuros.efi\n")
    (esp / "loader/loader.conf").write_text("default neuros.conf\ntimeout 3\n")
    return None
