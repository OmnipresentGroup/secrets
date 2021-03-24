# secrets

## How to add people to the trusted list

1. Add an URL to their public keys on [trusted-user-keys.txt](./trusted-user-keys.txt).
2. Re-encrypt the shared-private.gpg.secrets by running `./re-encrypt-shared-key.sh`.
3. Submit and merge a PR with the updated file.

## How to remove people from the trusted list, Or what to do when secrets are compromised

Beware that simply removing them from the list and re-encrypting the secrets is _not enough_. For a full thorough removal, you should revoke any credentials stored in secrets before re-encrypting them. This is also valid for the CI GPG key. See section below on how to update it.

## How to update the shared GPG key (also used by CI/CD)

For CI to be able to decrypt secrets, its _private_ GPG key is provided as an environment variable named `GPG_PRIVATE_KEY`.

The recommended way to update the CI/CD key is by generating a new one, wityh the steps below.

1. If you ever imported the CI/CD key before, delete it with:

```
gpg --delete-secret-key cicd@omnipresent.com
gpg --delete-key cicd@omnipresent.com
```

1. Run `gpg --full-generate-key` to [generate a new key](https://docs.github.com/articles/generating-a-gpg-key/) that:

   - Does not expire
   - With `cicd@omnipresent.com` as its email address
   - No passphrase

2. Update its local copies with:

```
gpg --sign-key cicd@omnipresent.com
gpg --armor --export cicd@omnipresent.com > ./secrets/cicd-public.gpg
gpg --armor --export-secret-key cicd@omnipresent.com | ./secrets/encrypt.sh > ./secrets/cicd-private.gpg.secrets
```

3. Update the [GPG_PRIVATE_KEY var on Circle](https://app.circleci.com/settings/project/github/OmnipresentGroup/OmniPlatform-api/environment-variables) with the output of `gpg --armor --export-secret-key cicd@omnipresent.com | tr '\n' ','`. Beware that updating this will likely break other builds. Please, coordinate with others.

2. Re-encrypt the shared-private.gpg.secrets by running `./re-encrypt-shared-key.sh`.

Note that you shouldn't use these steps for _your own personal keys_. For those, unless you private key gets compromised, you should always update the existing key or subkeys.
