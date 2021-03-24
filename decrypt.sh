#!/usr/bin/env sh
set -eu

usage() {
  echo >&2 "Usage: $0 [input-file] [output-file]"
  echo >&2 "  input-file can be '-' for /dev/stdin. Default: -"
  echo >&2 "  output-file can be '-' for /dev/stdout. Default: \${input-file} without '.secrets' or -"
}

here="$(dirname "$0")"
input="${1:--}"
output="${2:-}"

if [ -t 0 ] && [ "$input" = '-' ]; then
  usage
  exit
fi
if [ "$input" != '-' ]; then
  input="$(echo "$input" | sed 's/\([.]secrets\)\{0,1\}$/.secrets/')"
fi
if [ -z "$output" ]; then
  if [ -t 1 ] && [ "$input" != '-' ]; then
    output="$(echo "$input" | sed 's/[.]secrets$//')"
  else
    output='-'
  fi
fi

if [ "${CI:-}" ]; then
  "${here}/import-trusted-keys.sh"
fi

if [ "${GPG_PRIVATE_KEY:-}" ]; then
  # CI systems don't deal well with line-breaks in env vars. To generate the a GPG_PRIVATE_KEY for them, try:
  # `./decrypt.sh shared-private.gpg.secrets | tr '\n' ',' | pbcopy`

  echo >&2 "=> Importing GPG_PRIVATE_KEY..."
  echo "$GPG_PRIVATE_KEY" | sed 's/[,]/\n/g' | gpg --import - >&2
else
  echo >&2 "=> Importing shared-private.gpg..."
  gpg -qd "${here}/shared-private.gpg.secrets" 2> /dev/null | gpg -q --import -
fi

# TODO: consider verifying GPG signature of the last commit that changed secrets with:
# git verify-commit "$(git rev-list -1 HEAD ./secrets/)"

echo >&2 "=> Decrypting ${input} -> ${output} with GPG passphrase..."
(set -x && gpg -qd --yes -o "${output}" "${input}")
