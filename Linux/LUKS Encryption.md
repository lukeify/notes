# LUKS Encryption

LUKS (Linux Unified Key Setup) is a disk encryption specification, and the `cryptsetup` package can create encrypted block devices utilising this specification.
These block devices can be unlocked using passphrases, keyfiles, or even FIDO2 devices.

There exists two main version of LUKS.
The original version is now discouraged in favour of LUKS2 (`cryptsetup`by default will use LUKS2), which utilises the `Argon2` key derivation function whilst the original version utilised `PBKDF2`.
[This answer goes into further detail on the differences][1].

## Why block encryption?

Encrypted block devices offer security advantages over filesystem encryption schemes by encrypting the filesystem _itself_.
For example, tools like `gocryptfs` can encrypt files within an image, but the file sizes themselves are not obscured and can be calculated—[this means it's possible for someone with access to your encrypted filesystem to determine if you hold certain files if they also hold them][2].
Deducing you have a music album based on the file sizes of the contents, for example.

On the other hand, block device encryption has some drawbacks.
Backing up to cloud storage requires a full re-upload of the block image every time the contents change, for example.
Whereas with `gocryptfs` only the changed (encrypted) files within the image need be uploaded.

More general information about device encryption can be found in the [Arch Linux wiki][3].

## Setup

Begin by creating a file of a specific size using the `dd` tool.
This will write zeroes to an output file that will be 1GB in size.

```shell
dd if=/dev/zero of=/contents.image bs=1M count=1024
```

Options:

- `if` input file (`/dev/zero` being a stream of zeroes).
- `of` output file
- `bs` refers to the block-size in bytes.
- `count` copies `bs` number of blocks.

Set up a _loop device_ the file should be associated with, using `losetup`
A loop device is a file/pseudo-device that acts as a block-based device.

```shell
sudo losetup -f --show contents.image
```

Alternatively, instead of `-f` and `--show`, the name of a specific device could be given, for example `/dev/loop1`.

- `-f` will find the first free loop device available for you.
- `--show` will then print the name of that loop device.

Now with the loop device is associated with the encrypted file, we can format its contents.
This will product a warning indicating anything in the device will be overwritten, but this is okay since we generated the file with `dd` anyway.

Note that by default this command will use the `LUKS2` format:

```shell
sudo cryptsetup luksFormat /dev/loop1
```

`cryptsetup` will ask for a passphrase—this can be left blank since the keyslot this passphrase will be inserted into will be deleted anyway once a FIDO2 device is associated with the device.
More details on `cryptsetup` can be read on the [Arch Linux wiki][4], whilst the `cryptsetup` [man page][5] is incredibly useful when needing to refer to its subcommands.
Next, add a FIDO2 keyslot to the device using `systemd-cryptenroll`:

```shell
sudo systemd-cryptenroll /dev/loop1
--wipe-slot=all
--fido2-device=auto \
--fido2-with-user-presence=yes \
--fido2-with-user-verification=yes
```

Note the use of `--wipe-slot=all` will remove all other keyslots associated with the device, including the empty passphrase we created it with.
`--fido2-device=auto` will automatically find the inserted FIDO2 device.

### FIDO2 options

`systemd-cryptenroll` provides a number of FIDO2 options when associating a FIDO2 device with a LUKS-encrypted file.
These are documented in the [man page for `systemd-cryptenroll`][6].
These broadly correspond to some of the options present in the [FIDO2.1 spec][7] for when keys broadcast what features they support.

#### User presence

This requires that a user place their finger on the capacitive touch sensor of the YubiKey—note that it is not a fingerprint reader, and does not confirm the user's identity.
Nonetheless, this is sufficient as a factor for two-factor authentication, as it confirms the device is in the hands of the user logging in.
This option is known as `up`.

#### User verification

"User verification" is considered to be an attestation that user has verified they are the owner/operator of the YubiKey.
This may be done through biometric identification (such as a fingerprint sensor on the device).
For the purposes of two-factor authentication, [this mechanism is discouraged][8]:

> User verification is not recommended for 2FA because the user will have already entered a shared secret (password) sent to the server over the network.
> In this case, explicitly set userVerification to discouraged.
> Otherwise, a superfluous user verification step will be required for users that have set a PIN or enrolled a fingerprint on their security key, creating a bad user experience.

This option is known as `uv`.

#### Client PIN

Distinct from `uv`, the `clientPin` option is not considered an example of "user verification".
This is made clear in the [FIDO2.1 spec][9]:

> ClientPIN is one of the overall ways to do user verification, although ClientPIN is not considered a built-in user verification method.

Some additional information on the user-facing side of [YubiKey PINs][10].

With the device now configured with the preferred authentication mechanism it can now be opened.
This command will present a message to the user to attest via their FIDO2 device.
Once confirmed, a device mapper will be present at `/dev/mapper/contents.unencrypted`.

```shell
sudo cryptsetup open /dev/loop1 contents.unencrypted
```

This can now be initialised with a filesystem (in this example, EXT4):

```shell
sudo mkfs.ext4 /dev/mapper/contents.unencrypted
```

Finally, it can be mounted:

```shell
sudo mount /dev/mapper/contents.unencrypted /mnt
```

The filesystem will now be accessible in the `/mnt` directory.

## Open a LUKS-encrypted block device

Shorthand commands:

```shell
sudo losetup -f --show contents.image
# Requires FIDO2 device to be plugged in.
sudo cryptsetup open /dev/loop1 contents.unencrypted
sudo mount /dev/mapper/contents.unencrypted /mnt
```

## Close a LUKS-encrypted block device

Shorthand commands:

```shell
sudo umount /mnt
sudo cryptsetup close contents.encryptedvol
sudo losetup -d /dev/loop1
```

## Statuses & Querying

List loop devices configured:

```shell
sudo losetup --list
```

List device-mappers that are managed by `cryptsetup`:

```shell
sudo dmsetup ls --target crypt
```

List mounted block devices:

```shell
sudo lsblk -f
```

## Other reading

- [Ergonomics of `cryptsetup`][11]

[1]: https://askubuntu.com/a/1259424
[2]: https://nuetzlich.net/gocryptfs/threat_model/
[3]: https://wiki.archlinux.org/title/Data-at-rest_encryption
[4]: https://wiki.archlinux.org/title/Dm-crypt/Device_encryption
[5]: https://www.man7.org/linux/man-pages/man8/cryptsetup.8.html
[6]: https://manpages.debian.org/testing/systemd/systemd-cryptenroll.1.en.html
[7]: https://fidoalliance.org/specs/fido-v2.1-ps-20210615/fido-client-to-authenticator-protocol-v2.1-ps-errata-20220621.html
[8]: https://developers.yubico.com/WebAuthn/WebAuthn_Developer_Guide/User_Presence_vs_User_Verification.html
[9]: https://fidoalliance.org/specs/fido-v2.1-ps-20210615/fido-client-to-authenticator-protocol-v2.1-ps-errata-20220621.html#authenticatorGetInfo
[10]: https://support.yubico.com/hc/en-us/articles/4402836718866-Understanding-YubiKey-PINs
[11]: https://www.thegeekstuff.com/2016/03/cryptsetup-lukskey/
