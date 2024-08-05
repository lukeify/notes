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

### Debian 12 Stable Vanilla

An initial attempt ino

https://forums.debian.net/viewtopic.php?t=158270

#### Intel WiFi Microcode

#### Sof-sound

### Kernel Support

### Compiling an ISO image (Live Builds?)

https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html

[1]: https://www.debian.org/intro/free
[2]: https://www.gnu.org/philosophy/free-sw.html
[3]: https://www.debian.org/intro/why_debian
