#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export QT_QUICK_BACKEND=software
export QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-offscreen}
bash "$root/scripts/preview.sh" --check-ui
for scale in 1 1.5; do
  QT_SCALE_FACTOR=$scale "$root/build/neuros-installer" --compact \
    --screenshots "$root/build/live-checks/scale-$scale"
done
