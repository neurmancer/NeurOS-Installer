"""Apply the application choices to the offline, copied live filesystem."""
from pathlib import Path
import subprocess
import libcalamares

OPTIONAL_APPS = frozenset(("firefox", "dolphin"))


def pretty_name():
    return "Applying application choices"


def run():
    root = Path(libcalamares.globalstorage.value("rootMountPoint") or "/").resolve()
    if root == Path("/") or not (root / "etc/os-release").is_file():
        return ("Invalid target", "A mounted target system is required.")
    operations = libcalamares.globalstorage.value("packageOperations") or []
    selected = set()
    for operation in operations:
        if not isinstance(operation, dict):
            return ("Invalid application selection", "Package selection data is invalid.")
        for key in ("install", "try_install"):
            for item in operation.get(key, []):
                name = item if isinstance(item, str) else item.get("package", "")
                if name in OPTIONAL_APPS:
                    selected.add(name)
    # Verify the image really contains every offered package. Otherwise a checked
    # option could silently result in a missing application after installation.
    for name in sorted(OPTIONAL_APPS):
        result = subprocess.run(["pacman", "--root", str(root), "-Q", name],
                                stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
        if result.returncode:
            return ("Application unavailable", f"{name} is missing from the installation image.")
    remove = sorted(OPTIONAL_APPS - selected)
    if remove:
        result = subprocess.run(["pacman", "--root", str(root), "-R", "--noconfirm", *remove],
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        if result.returncode:
            return ("Could not apply application choices", result.stdout[-4000:])
    return None
