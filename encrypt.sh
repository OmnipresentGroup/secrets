#!/usr/bin/env sh
set -eu

usage() {
  echo >&2 "Usage: $0 [input-file] [output-file]"
  echo >&2 "  input-file can be '-' for /dev/stdin. Default: -"
  echo >&2 "  output-file can be '-' for /dev/stdout. Default: \${input-file}.secrets or -"
}

here="$(dirname "$0")"
input="${1:--}"
output="${2:-}"

if [ -t 0 ] && [ "$input" = '-' ]; then
  usage
  exit
fi
if [ "$input" != '-' ]; then
  input="$(echo "${input}" | sed 's/[.]secrets$//')"
fi
if [ -z "$output" ]; then
  if [ -t 1 ] && [ "$input" != '-' ]; then
    output="${input}.secrets"
  else
    output='-'
  fi
fi

user_keys_path="${here}/user-keys"
if [ ! -r "${user_keys_path}" ] || find "${here}" -newer "${user_keys_path}" -maxdepth 1 | grep -q ^; then
  echo >&2 "=> Getting trusted keys..."
  rm -rf "${user_keys_path}/"
  mkdir -p "${user_keys_path}/"
  cat "${here}/trusted-user-keys.txt" | while read -r key_url; do
    key_filename="$(basename "$key_url" | sed 's/[?].*$//')"
    curl -sS "$key_url" > "${user_keys_path}/${key_filename}"
  done
fi

echo >&2 "=> Encrypting ${input} -> ${output} with GPG..."
recipients="$(find "${user_keys_path}" -type f -depth 1 | sed 's/^/--recipient-file /g' | tr '\n' ' ')"
(set -x && gpg -sea --yes \
  --recipient-file "${here}"/shared-public.gpg \
  ${recipients} \
  -o "${output}" "${input}")
