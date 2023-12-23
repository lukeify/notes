# PiHole on UnifiOS 3

I previously have [written a guide][1] for my own benefit on how to configure PiHole running inside a UniFi Dream Machine (UDM) running UniFi OS 1.x.
This guide amends those instructions for UniFi OS 3.x, which contains large architectural changes by using [`nspawn`][3] instead of `podman`—which was used by UniFi OS 1.x—is no longer supported as a containerization implementation.

We will be following the [unifi-utilities/unifios-utilities guide][2], repeated here for clarity, with some minor personal preference adjustments to configuration.
This involves using `systemd-nspawn` to create a container that will run our `pihole` functionality, that can be controlled via `machinectl`.

## Steps

### SSH into your Unifi console

1. Under the _OS Settings_ tab in your UniFi console, click _Console Settings_ → _Advanced_ and tick the _SSH_ checkbox.
2. Under the _Network_ tab in your UniFi console, click _System_ → _Advanced_ and tick the _Device SSH Authentication_ checkbox.
   Set a username and password.
   I believe only one of these settings needs to be configured for SSH to be enabled.

3. I also add a `Host` configuration into my `.ssh/config` to make this less typing:

    ```ssh
    Host udm
        User root
        HostName 192.168.1.1
    ```

4. SSH into your UniFi console.

### Container creation and configuration

1. Install `systemd-container` and `debootstrap` to create a directory with a base debian system, and then use `systemd-nspawn` to boot the container.

    ```shell
    apt -y install systemd-container debootstrap
    ```

2. Create a `pihole` directory containing a base debian system in `/data/custom/machines`.

    ```shell
    mkdir -p /data/custom/machines
    cd /data/cstom/machines
    debootstrap --include=systemd,dbus unstable pihole
    ```

3. Once ready, we can create a shell to this container and perform some initial configuration by setting a password, enabling networking, and setting our DNS resolver to cloudflare.

    ```shell
    systemd-nspawn -M pihole -D /data/custom/machines/pihole
    passwd root # Set your password here
    systemctl enable systemd-networkd
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
    echo "pihole" > /etc/hostname
    exit
    ```

4. Now, on the host OS of the UDM device, link the container to `/var/lib/machines` so we can control it with `machinectl`.

    ```shell
    mkdir -p /var/lib/machines
    ln -s /data/custom/machines/pihole /var/lib/machines
    ```

### Firmware persistence

### Pihole configuration

## FAQ

## Todos

1. Cannot login with credentials specified in `Device SSH Authentication`.

---

### Step 2. Configure the container

1. Substep 1: used directory name `pihole` instead.
2. Substep 2: created a file with the name `pihole.nspawn` instead.
   Jumped to Step 2A.

### Step 2A. Configure the container to use an isolated MacVLAN network

1. Substep 1
    1. Set VLAN to `2`.
    2. Changed `IPV4_GW` to `192.168.2.1/26` (this matches my previous configuration)
    3. Changed `IPV4_IP` to `192.168.2.2` (this matches my previous configuration)
    4. Set `IPV6_GW` and `IPV6_IP` to empty strings (check if we can enable this later??)
2. Substep 2:
    1. _Added_ `MACVLAN=br2` to the `pihole.nspawn` file. Maybe this is meant to be a replacement and not an addition??
3. Substep 3:

    1. Created a `mv-br2.network` file at `/data/custom/machines/pihole/etc/systemd/network` with settings as described:

        ```network
         [Match]
         Name=mv-br2

         [Network]
         IPForward=yes
         Address=192.168.2.2/26
         Gateway=192.168.2.1
        ```

4. Substep 4: I see `inet 192.168.2.2/26 brd 192.168.2.63 scope global mv-br2`. Is the address after brd right?
5. Substep 5: Installed the [udm boot script][4] (as mentioned in step 1 of my previous install guide). Back to main step 2.

### Back to Step 2

1. Substep 3: container was already running so `start` not needed.
    1. Executed `machinectl enable pihole` (start container on boot)
2. Substep 4: confirmed shell and login access.
3. Substep 5: no action needed.

### Step 3. Configure Persistence Across Firmware Updates

1. Substep 1: Just cd'd, didn't need to create directory.
2. Substep 2: Seemed to execute fine, but received warning:

    ```
    W: Download is performed unsandboxed as root as file '/data/custom/dpkg/arch-test_0.17-1_all.deb' couldn't be accessed by user '_apt'. - pkgAcquire::Run (13: Permission denied)
    ```

3. Substep 3: no action needed.

### [How to install Pi-Hole in Container][5]

1. Step 1 done
2. Step 2. I had to go back and add `"nameserver 1.1.1.1" > /etc/resolv.conf` to the container to install packages.
3. Step 3 done
4. Step 4 done. Selected cloudflare.
5. Step 5 done. Selected no as I will install from existing configuration.
6. Step 6 done.
7. Step 7 done.
   Message on configuration initialization. Do I need to resolve?
    ```
    [✗] Unable to fill table adlist in database /etc/pihole/gravity.db
    Error: cannot open "/tmp/tmp.awdNvLc8bI"
    ```
8. Step 8. IP and admin password did not appear?
9. Step 9. Used command to set password to previous pihole instance.
10. Step 10. Confirmed that 192.168.2.2/admin is accessible (pi.hole is not resolving though).
    I then attempted to restore my previous pihole configuration from backup. But teleporter would not accept a .tar file. I don't know how I ended up with this. I had to unarchive the tar file, and then recompress it as a tar.gz file via `tar czf [file] [folder]`. It seems like only some of the settings were restored though? Long term query statics were not restored.
11. Step 11. Permitted all origins.
12. Went back and ran `apt clean`.
13. Updated gravity (Pihole admin UI -> Tools -> Update gravity) and domains on adlists became the correct number again.
14. Rebooted pihole (Pihole admin UI -> Settings -> etc etc). This changed the versioning in the bottom from "N/A" to "vDev"
15. Ran `pihole updatechecker`. Correct version numbers now showing.
16.

## Todos

1. ~~Set `pi.hole` to point to `192.168.2.2`~~ This resolved itself.
2. Find out how to backup long term query statistics.
3. ~~Find out how to set Pi-hole, FTL, and web interface versions at the bottom of the admin UI.~~ Resolved by running `pihole updatechecker`.
4. ~~Why is "domains on adlists" is "-2"~~ Resolved by updating gravity.

## Notes

-   Specifying `ssh-rsa` is no longer needed to SSH into the device.
    This was resolved in UnifiOS 2.4.x.

https://github.com/unifi-utilities/unifios-utilities/tree/main/nspawn-container
https://discourse.pi-hole.net/t/why-should-pi-hole-be-my-only-dns-server/3376
https://superuser.com/questions/258151/how-do-i-check-what-dns-server-im-using-on-mac-os-x

[1]: https://gist.github.com/lukeify/96e73218b4de79891a46a89fdc2c2045
[2]: https://github.com/unifi-utilities/unifios-utilities/tree/main/nspawn-container
[3]: https://wiki.debian.org/nspawn
[4]: https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script
[5]: https://github.com/unifi-utilities/unifios-utilities/blob/main/nspawn-container/examples/pihole/README.md
