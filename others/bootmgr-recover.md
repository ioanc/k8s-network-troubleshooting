
+ Atach iso to iLO VirtualDrivers URL CD-ROM/DVD

```
http://tinycorelinux.net/16.x/x86/release/Core-current.iso
```

+ Restart server

+ Press F11 and select to boot from CD-ROM

+ On the tc console check ntfs partition

```
blkid /dev/sd* | grep -i ntfs
```

+ Install ntfs-3g, to be able to mount the partition and write on it

```
tce-load -wi ntfs-3g
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
