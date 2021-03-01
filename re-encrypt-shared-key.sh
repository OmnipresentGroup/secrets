#!/usr/bin/env sh
set -eu

./decrypt.sh shared-private.gpg.secrets | ./encrypt.sh - shared-private.gpg.secrets
