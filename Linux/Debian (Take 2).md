# Debian (Take 2)

## Semi-livable base system to use live-build from

Installed `debian-12.6.0-amd64-DVD-1.iso` via Graphical Installation (Expert)

Added user to root using `usermod -a -G sudo luke`.

Installed `linux-image-6.10.4-amd64` debian package manually via `dpkg -i` (from `trixie`).

- This gave me trackpad support.

Installed `firmware-iwlwifi-20240709-1` debian package manually via `dpkg -i` (from `trixie`).

- This gave me WiFi support.

Updated `/etc/apt/sources.list` away from the DVD installation to the standard bookworm+backports source list.

Ran `sudo apt update` & `sudo apt upgrade`. This reinstalled the original linux kernel (6.1)

Added `trixie` to `sources.list`.

Added a `preferences.d/testing` setting all packages to priority 100, then `linux-image-*` and `linux-headers-*` to 1001.

Installed both with `apt-get install -t testing`

Installed `vim`.

Added a Pin-Priority of 1001 for `firmware-misc-nonfree` to install `20240709` to solve missing i915 drivers.

- This may also install firmware to resolve sound?
- This may install too much firmware? I don't need mediatek or nvidia drivers.

Installed `git` and `live-build`

Installed `speedtest-cli`

Installed `Bitwarden.appimage` and moved to `~/Applications`

Added GPG key to git.

Install `qemu-kvm` `qemu-utils` for the purposes of live-build testing.

Installed and configured `apt-cacher-ng`

## live-build specific configuration

Create a fake "disk" for live-build to install to with `qemu-img create -f disk_image.qcow2 12G`
Attempted to test the live-build with `kvm -m 2048M -cdrom live-image-amd64.hybrid.iso -hda disk_image.qcow2 -boot d`
