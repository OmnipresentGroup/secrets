#!/usr/bin/env sh
set -eu

# This script can be executed via:
# curl -sSL https://github.com/OmnipresentGroup/secrets/raw/main/install.sh | sh

if [ -d ./secrets/.git ]; then
  echo "=> Secrets repo seems to exist, pulling changes…"
  (cd secrets && git pull --rebase)
else
  if [ -d ./secrets ]; then
    echo "=> Deleting non-git ./secrets folder …"
    (set -x && rm -rf ./secrets)
  fi

  # if on CI or git is not available
  if [ "${CI:-}" ] || ! git --version > /dev/null 2>&1; then
    curl -sSL --output - https://github.com/OmnipresentGroup/secrets/archive/refs/heads/main.tar.gz | tar -xvzf -
    mv secrets-main secrets
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
fi


