# Debian

Goal of debian is to provide a highly stable, "free" operating system (the user is however able to install non-free components).
[Debian provides their own definition of "free"][1], which seems mostly compatible with the [GNU definition of "free"][2].
]Debian provides its own list of reasons to use][3].

`bookworm` is the current release ("stable")—also called Debian 12, which was released on 10 June 2023.
The latest point release from `bookworm` is Debian 12.6, released on 29 June 2024.
`trixie` is the next release ("testing"), and will be Debian 13.
It does not yet have a scheduled release date.
Packages that have been backported from `trixie` to `bookworm` are available on what's referred to as "backports", which can be added as a separate package source in `/etc/apt/sources.list`.

Being a highly stable OS, many newly-released devices with new chipsets or internal products may be "too new" to run Debian stable without modification.
This happens to be the case with the Lenovo ThinkPad X1 Carbon (12th gen) laptop.

## Debian-Kernel package matrix

Debian 12 currently ships with Linux Kernel 6.1.99 (`linux-image-6.1.99-amd64`).
Debian 12 `backports` contains Linux Kernel 6.9.7 (`linux-image-6.9.7+bpo-amd64`). https://packages.debian.org/source/bookworm-backports/linux-signed-amd64
Debian `trixie` contains Linux Kernel 6.9.12 (`linux-image-6.9.12-amd64`). https://packages.debian.org/source/trixie/linux-signed-amd64

TODO:

- What is a metapackage?

## Images

https://www.debian.org/releases/bookworm/debian-installer/

### netinst images

### CD/DVD Images

These images are a metaphor for when users would literally insert a CD or DVD into their optical disk to boot and install Debian, and as such are capacity-limited to those storage mediums.
The DVD images usually contain enough packages for

## Apt preferences

https://wiki.debian.org/SourcesList
https://wiki.debian.org/AptConfiguration

## GNOME vs XFCE?

Desktop environments.
Both can be installed simultaneously.

## Goal: Run Debian 12 on a Lenovo ThinkPad X1 Carbon (12th gen)

This laptop is too new to run Debian 12 vanilla in an acceptable way without modification.
Some of the issues encountered:

* The kernel was not up to date enough, and `6.9` is needed (Intel docs suggest `6.10` is needed?)
* Firmware to use the Wi-Fi 6E AX211 card was not present (and was asking for microcode files), so installing `firmware-iwlwifi` at version `20240709` was needed.
  https://www.intel.com/content/www/us/en/products/sku/204837/intel-wifi-6e-ax211-gig/specifications.html
* No sound was available, as an update to `firmware-sof-signed` to `xxx` was needed.

https://forums.debian.net/viewtopic.php?t=158270

Remember to install linux headers!

```
sudo apt -t bookworm-backports install linux-headers-amd64
```

#### Kernel (`linux-image-6.9.7+bpo-amd64`)

#### Intel WiFi Microcode (`firmware-iwlwifi_20240709-1`)

Maybe not needed if kernel update is provided?

#### Sof-sound (`firmware-sof-signed_`)

### Kernel Support

### Kernel Modules

Tools:

* modprobe
* lsmod
* insmod
* rmmod

### Compiling an ISO image (Live Builds?)

Initial guide followed: https://ianlecorbeau.github.io/blog/debian-live-build.html

```sh
#!/bin/sh
lb config -d bookworm --backports true \
    --debian-installer live \
    --debian-installer-distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debootstrap-options "--variant=minbase" \
    --linux-packages "linux-image-6.9.7+bpo"

# Define where to fetch the kernel from
# https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-package-installation.en.html#429
echo "deb http://deb.debian.org/debian/ bookworm-backports main" > config/archives/bookworm-backports.list.chroot

# TODO:
# Ensure that recommended packages we actually want to install are present
# Not probably needed if apt-recommends is true
# https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-package-installation.en.html
# echo "user-setup sudo" > config/package-lists/recommends.list.chroot

# Define packages to install
cat <<EOF >> config/package-lists/pkgs.list.chroot
    firefox-esr
    firmware-iwlwifi
    firmware-sof-signed
    git
    iputils-ping
    network-manager
    network-manager-gnome
    vim
    xfce
    xfce-goodies
    yt-dlp
EOF

# TODO:
# Define the Pin-Priority of the packages we want.
# We need this to ensure packages are installed with the correct version.
# https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-package-installation.en.html#389
cat <<EOF >> TODO:
EOF

# Compiling `tirdad` kernel module by merging in the single change from the upstream `0xsirus` remote that wasn't included in Kicksecure.
# TODO: Need to set git config
git clone --depth 1 https://github.com/Kicksecure/tirdad.git
git remote add original https://github.com/0xsirus/tirdad.git
git fetch original
git merge original/master

# Need to provide dummy `tirdad` and `tirdad-dkms` package so kicksecure does not attempt to install.
sudo apt install equiv (whatever its called)

# `xfce4` auto-configuration
mdkir -p config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/
cat <<EOF >> config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Gdk/WindowScalingFactor" type="int" value="2"/>
</channel>
EOF
```

Speed up live builds by using `apt-cacher-ng`

TODO: how to test?
Answer: live boot USB? Guide about how to use KVM in live build manual

#### `tirdad` stuff
I had to symlink in the linux-headers directory into `/lib/modules/$(uname -r)/build` as well?

```
ln -sf /usr/lib/$(uname -r)/* /lib/modules/$(uname -r)/build
```

Once built, install via:

```
install -D -m 644 tirdad.ko /lib/modules/$(uname -r)/extra/tirdad.ko
depmod -a $(uname -r)
```

then verify the module exists:

```
modprobe tirdad
```

insmod tirdad gives a segmentation fault at `cet.c`

Maybe try setting ibt=off?

##### `xfce4` configuration

Configuring XFCE4 window appearance:

Copy files into `config/includes.chroot` into the right subdirectory from there.

TODO:

Try setting: `firmware=never live-installer/enable=false` as boot parameters
https://wiki.debian.org/Firmware
https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-installer.en.html

https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html

## Whonix installation

Install in KVM

https://old.reddit.com/r/Whonix/comments/1721pnw/how_can_i_combine_the_antiforensics_benefits_from/
https://unix.stackexchange.com/questions/779663/how-to-load-firmware-for-wifi-ax211-in-debian-trixie/779664#779664
https://unix.stackexchange.com/questions/676105/missing-non-free-firmware-during-debian-installation
https://community.intel.com/t5/Wireless/AX211-160MHz-wifi-problem-on-proxmox-pve-debian/m-p/1562446

[1]: https://www.debian.org/intro/free
[2]: https://www.gnu.org/philosophy/free-sw.html
[3]: https://www.debian.org/intro/why_debian
