"""Fail before partition jobs when the live image or disk inventory changes."""
import json
from pathlib import Path
import subprocess

def pretty_name():
    return "Rechecking storage identity"

def disks(data):
    return sorted((d for d in data["blockdevices"] if d["type"] == "disk"), key=lambda d: d["path"])

def run():
    snapshot = Path('/run/neuros-installer/disks.json')
    if not snapshot.is_file() or not Path('/run/archiso/bootmnt/neuros/x86_64/airootfs.sfs').is_file():
        return ('Launch verification failed', 'Start installation through Install NeurOS in the live session.')
    current = json.loads(subprocess.check_output(['lsblk', '--json', '--bytes', '--nodeps', '--output', 'PATH,MAJ:MIN,SIZE,MODEL,SERIAL,WWN,RO,TYPE']))
    if disks(current) != disks(json.loads(snapshot.read_text())):
        return ('Storage changed', 'Restart the installer and review the disk operations again.')
    return None
