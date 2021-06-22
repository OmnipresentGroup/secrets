#!/usr/bin/env sh
set -eu

./decrypt.sh ./shared-private.gpg.secrets > /dev/null

echo
echo "TEST PASSED. You're ready to decrypt/encrypt secrets."
