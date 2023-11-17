# GPG

I used the following guides to configure a GPG key for use with `git`, in this order:

1. [Generating a new GPG key][1]
2. [Adding a GPG key to your GitHub account][2]
3. [Telling Git about your signing key][3]

Finally and crucially, how to configure both autosigning within git as well as adding the GPG key to macOS keychain so a password is not required per commit:

```sh
git config --global commit.gpgsign true
brew install pinentry-mac
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg.conf
gpgconf --kill gpg-agent
```

Taken from "[Sign git commits on GitHub with GPG in macOS][4]"

[1]: https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
[2]: https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account
[3]: https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key
[4]: https://samuelsson.dev/sign-git-commits-on-github-with-gpg-in-macos/