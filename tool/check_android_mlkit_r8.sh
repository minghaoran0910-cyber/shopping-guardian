#!/usr/bin/env bash
set -euo pipefail

mapping_file="${1:-build/app/outputs/mapping/release/mapping.txt}"
if [[ ! -f "$mapping_file" ]]; then
  echo "R8 mapping not found: $mapping_file" >&2
  exit 1
fi

registrars=(
  "com.google.mlkit.common.internal.CommonComponentRegistrar"
  "com.google.mlkit.vision.common.internal.VisionCommonRegistrar"
  "com.google.mlkit.vision.text.internal.TextRegistrar"
)

for registrar in "${registrars[@]}"; do
  block="$(
    awk -v registrar="$registrar" '
      index($0, registrar " ->") { found = 1; remaining = 8 }
      found && remaining > 0 { print; remaining-- }
    ' "$mapping_file"
  )"
  if [[ -z "$block" ]]; then
    echo "ML Kit registrar missing from release mapping: $registrar" >&2
    exit 1
  fi
  if ! grep -Fq "void <init>()" <<<"$block"; then
    echo "R8 removed the reflective no-argument constructor: $registrar" >&2
    exit 1
  fi
done

echo "ML Kit release registrars retain their reflective constructors."
