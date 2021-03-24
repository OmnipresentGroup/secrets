#!/usr/bin/env sh
set -eu

if [ ! -d ./secrets ]; then
  if [ "${CI:-}" ]; then
    curl -sSL --output - https://github.com/OmnipresentGroup/secrets/archive/refs/heads/main.tar.gz | tar -xvzf -
    move secrets-main secrets
  else
    if grep -q 'OmnipresentGroup/secrets' ../secrets/.git/config 2> /dev/null; then
      echo "=> Linking ./secrets to ../secrets …"
      (set -x && ln -s ../secrets/ secrets)
      (cd secrets && git pull --rebase)
    else
      echo '=> Cloning secrets repo into ./secrets …'
      echo '   If you have the secrets repo cloned somewhere, you can run:'
      echo '$ ln -s {path_to_your_local_repos}/secrets/ secrets'
      (set -x && git clone git@github.com:OmnipresentGroup/secrets.git)
    fi
  fi
else
  (cd secrets && git pull --rebase)
fi


