import importlib.util
from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
storage = types.SimpleNamespace(value=lambda key: "/")
sys.modules["libcalamares"] = types.SimpleNamespace(globalstorage=storage)

def module(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / "src/modules" / name / "main.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

class BackendTests(unittest.TestCase):
    def test_host_root_is_rejected(self):
        for name in ("neuroscleanup", "neurosboot"):
            with patch("subprocess.run") as run:
                self.assertEqual(module(name).run()[0], "Invalid target")
                run.assert_not_called()

    def test_live_cleanup_is_scoped_to_target(self):
        mod = module("neuroscleanup")
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in ("etc/os-release", "etc/sudoers.d/10-neuros-live", "etc/sudoers.d/custom", "etc/mkinitcpio.d/linux-neuros.preset"):
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("fixture")
            with patch.object(storage, "value", return_value=directory), patch.object(mod.subprocess, "run", return_value=types.SimpleNamespace(returncode=0)) as run:
                self.assertIsNone(mod.run())
                self.assertFalse((root / "etc/sudoers.d/10-neuros-live").exists())
                self.assertTrue((root / "etc/sudoers.d/custom").exists())
                for call in run.call_args_list:
                    self.assertEqual(call.args[0][:2], ["chroot", directory])

    def test_disk_identity_ignores_order_but_detects_replacement(self):
        mod = module("neurospreflight")
        a = {"type":"disk", "path":"/dev/vda", "serial":"a", "size":100}
        b = {"type":"disk", "path":"/dev/vdb", "serial":"b", "size":100}
        self.assertEqual(mod.disks({"blockdevices":[a,b]}), mod.disks({"blockdevices":[b,a]}))
        replacement = dict(a, serial="replacement")
        self.assertNotEqual(mod.disks({"blockdevices":[a]}), mod.disks({"blockdevices":[replacement]}))

if __name__ == "__main__":
    unittest.main()
