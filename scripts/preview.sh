#!/bin/bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cmake -S "$root" -B "$root/build" -G Ninja
cmake --build "$root/build"
exec "$root/build/neuros-installer" "$@"
