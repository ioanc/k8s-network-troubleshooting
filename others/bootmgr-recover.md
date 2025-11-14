
+ Atach iso to iLO VirtualDrivers URL CD-ROM/DVD

```
http://tinycorelinux.net/16.x/x86/release/Core-current.iso
```

+ Restart server

+ Press F11 and select to boot from CD-ROM

+ On the tc console install tools to check ip, connect remote, mount NTFS partition

```
tce-load -wi iproute2 dropbear ntfs-3g
```

+ On the tc console check ip and start dropbear

```
sudo ip addr && sudo dropbear -R -B -F -E
```

+ On the tc console or from remote check ntfs partition

```
blkid /dev/sd* | grep -i ntfs
```

+ Mount the partition

```
sudo mount -t ntfs-3g /dev/sda1 /mnt/sda1
```

+ Copy backup bootmgr file to the corrupted one

```
cp /mnt/sda1/bootmgr-ok /mnt/sda1/bootmgr
```

+ Unmount partition

```
sudo umount /mnt/sda1
```

+ Restart server

```
sudo reboot
```
