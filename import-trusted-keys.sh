#!/usr/bin/env sh
set -eu

here="$(dirname "$0")"

echo >&2 "=> Importing trusted keys (for signature verification)..."
cat "${here}/trusted-user-keys.txt" | xargs -tn1 -I% sh -c "curl -sS '%' | gpg --import - >&2"
