#!/usr/bin/env bash
set -euo pipefail

workflows=(
  ".github/workflows/macos-signed-release.yml"
  ".github/workflows/windows-signed-release.yml"
)

for workflow in "${workflows[@]}"; do
  if grep -Eq '^    env:' "$workflow"; then
    echo "Job-level env is forbidden in $workflow" >&2
    exit 1
  fi
  grep -Fq 'fetch-depth: 0' "$workflow"
  grep -Fq 'Require a revision from main history' "$workflow"
  grep -Fq 'git merge-base --is-ancestor HEAD origin/main' "$workflow"

  trust_line="$(grep -n -m1 'Require a revision from main history' "$workflow" | cut -d: -f1)"
  first_secret_line="$(grep -n -m1 '\${{ secrets\.' "$workflow" | cut -d: -f1)"
  if (( first_secret_line <= trust_line )); then
    echo "A secret is exposed before revision verification in $workflow" >&2
    exit 1
  fi
done

mac_secrets="$(
  grep -o '\${{ secrets\.[A-Z0-9_]* }}' "${workflows[0]}" |
    sed -E 's/.*secrets\.([A-Z0-9_]+).*/\1/' |
    sort -u
)"
expected_mac="$(
  printf '%s\n' \
    APPLE_API_ISSUER_ID \
    APPLE_API_KEY_BASE64 \
    APPLE_API_KEY_ID \
    MACOS_CERTIFICATE_BASE64 \
    MACOS_CERTIFICATE_PASSWORD \
    MACOS_SIGNING_IDENTITY
)"
if [[ "$mac_secrets" != "$expected_mac" ]]; then
  echo "Unexpected macOS release secret set" >&2
  diff <(printf '%s\n' "$expected_mac") <(printf '%s\n' "$mac_secrets") || true
  exit 1
fi

windows_secrets="$(
  grep -o '\${{ secrets\.[A-Z0-9_]* }}' "${workflows[1]}" |
    sed -E 's/.*secrets\.([A-Z0-9_]+).*/\1/' |
    sort -u
)"
expected_windows="$(
  printf '%s\n' WINDOWS_CERTIFICATE_BASE64 WINDOWS_CERTIFICATE_PASSWORD
)"
if [[ "$windows_secrets" != "$expected_windows" ]]; then
  echo "Unexpected Windows release secret set" >&2
  diff \
    <(printf '%s\n' "$expected_windows") \
    <(printf '%s\n' "$windows_secrets") || true
  exit 1
fi

echo "Release credential scope checks passed."
