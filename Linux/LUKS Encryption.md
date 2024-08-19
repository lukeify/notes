# LUKS Encrypted Blocks

## Setup

Generate a file of the given size:

```bash
dd if=/dev/zero of=/contents.encrypted bs=1M count=1024
```

* `if` input file (`/dev/zero` being a stream of zeroes).
* `of` output file
* `bs` refers to the block-size in bytes.
* `count` copies `bs` number of blocks.

Set up a _loop device_ the file should be associated with.

```bash
sudo losetup -f --show contents.encrypted
```

* `losetup`:
    * Instead of providing a loop device to associate with the file, `-f` will find the first free loop device available for you.
    * `--show` will then print the name of that loop device.

Encrypt the device using LUKS2 (the default when using LUKS):

```bash
sudo cryptsetup luksFormat /dev/loop1
```

Use an empty passphrase, since the keyslot this passphrase will be inserted into will be deleted anyway once a FIDO2 device is associated with the device.

Add a FIDO2 keyslot:

```bash
sudo systemd-cryptenroll /dev/loop1
--wipe-slot=all
--fido2-device=auto \
--fido2-with-user-presence=yes \
--fido2-with-user-verification=yes
```

* `--wipe-slot=all` will remove all other keyslots associated with the device.
* `--fido2-device=auto` will automatically find the inserted FIDO2 device.

TODO: integrate --fido2-with-client-pin

* `--fido`
* `--fido2-device`

Open the device:

```bash
sudo cryptsetup open /dev/loop1 contents.encrypted
```

Initialize an EXT4 filesystem:

```bash
sudo mkfs.ext4 /dev/mapper/contents.encrypted
```

## Open

Once created:

```bash
sudo losetup -f --show contents.encrypted
# Requires FIDO2 device to be plugged in.
sudo cryptsetup open /dev/loop1 contents.encryptedvol
sudo mount /dev/mapper/contents.encryptedvol /mnt
```

## Close

```bash
sudo umount /mnt
sudo cryptsetup close contents.encryptedvol
sudo losetup -d /dev/loop1
```

## Status & Querying

List loop devices configured:

```shell
sudo losetup --list
```

List device-mapper devices that are using crypt:

```shell
sudo dmsetup ls --target crypt
```

List mounted block devices:

```shell
sudo lsblk -f
```

https://www.man7.org/linux/man-pages/man8/cryptsetup.8.html
https://www.thegeekstuff.com/2016/03/cryptsetup-lukskey/
https://manpages.debian.org/testing/systemd/systemd-cryptenroll.1.en.html
