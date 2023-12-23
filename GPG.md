# GPG

## Creating a key

These guides provide one-time configuration for creating and storing a GPG key and associating it with your GitHub account:

1. [Generating a new GPG key][1]
2. [Adding a GPG key to your GitHub account][2]

This only needs to be done once, the configuration below then becomes per machine.

## Importing or configuring a key

To configure a key locally, or otherwise use an existing key on a machine:

-   [Telling Git about your signing key][3]
-   [Sign git commits on GitHub with GPG in macOS][4]

I used these guides to configure a GPG key to be used for autosigning via `git`, in this order:

```shell
# Add your signing key ID to git's config.
git config --global commit.signingkey $(gpg --list-secret-keys --keyid-format=long | awk '/^sec/ {split($2, a, "/"); print a[2]}')
# Automatically sign commits with the above key.
git config --global commit.gpgsign true
```

Finally we can use `pinentry-mac` to save our GPG credentials to macOS's keychain so we don't need to enter our key's password on every commit:

```shell
brew install pinentry-mac
# Which pinentry-mac needs to be outputted here as it changes depending on whether you're using an Intel or Apple Silicon Mac.
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
gpgconf --kill gpg-agent
```

Once a commit is made, you will be asked to allow `pinetry-mac` to add items to your macOS keychain to enable automatic signing going forward.

[1]: https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
[2]: https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account
[3]: https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key
[4]: https://samuelsson.dev/sign-git-commits-on-github-with-gpg-in-macos/
