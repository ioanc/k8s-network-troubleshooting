## Recover bootmgr via iLO

### Method 1: iLO SSH Console (iLO 3)

iLO 3 only supports legacy SSH algorithms, connect with:

```
ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 -oHostKeyAlgorithms=+ssh-dss Administrator@<ilo-ip>
```

+ Attach ISO via iLO CLI:

```
vm cdrom insert http://tinycorelinux.net/16.x/x86/release/Core-current.iso
vm cdrom set connect
```

+ Boot source mapping on iLO 3:

```
bootsource1 = BootFmCd
bootsource2 = BootFmFloppy
bootsource3 = BootFmDisk
bootsource4 = BootFmUSBKey
bootsource5 = BootFmNetwork
```

+ Set boot device first and reset:

CD-ROM:
```
set /system1/bootconfig1/bootsource1 bootorder=1
reset /system1
```

USB:
```
set /system1/bootconfig1/bootsource4 bootorder=1
reset /system1
```

+ Attach to the text console:

```
textcons
```

To exit the text console: **ESC (`** (Escape followed by `(`)

---

### TinyCore Console Steps

+ Install tools:

```
tce-load -wi iproute2 dropbear ntfs-3g
```

+ Check IP and start dropbear for optional remote SSH access:

```
sudo ip addr && sudo dropbear -R -B -F -E
```

+ Find the NTFS partition:

```
blkid /dev/sd* | grep -i ntfs
```

+ Mount the partition:

```
sudo mount -t ntfs-3g /dev/sda1 /mnt/sda1
```

+ Restore bootmgr from backup:

```
cp /mnt/sda1/bootmgr-ok /mnt/sda1/bootmgr
```

+ Unmount partition:

```
sudo umount /mnt/sda1
```

+ **Before rebooting**, restore disk as primary boot device (via iLO SSH):

```
set /system1/bootconfig1/bootsource3 bootorder=1
```

+ Restart server:

```
sudo reboot
```

---

### Method 2: iLO Web UI Console

+ Attach ISO to iLO Virtual Media via the web UI

```
http://tinycorelinux.net/16.x/x86/release/Core-current.iso
```

+ Restart server, press **F11** and select boot from CD-ROM

+ Run the TinyCore Console Steps above
