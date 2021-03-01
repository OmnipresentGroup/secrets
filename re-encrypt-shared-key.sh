#!/usr/bin/env sh
set -eu

./decrypt.sh shared-private.gpg.secrets | ENCRYPT_TO_USERS_TOO=1 ./encrypt.sh - shared-private.gpg.secrets
