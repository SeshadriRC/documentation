```bash
root@ip-172-31-11-100:~# lsblk
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 28.2M  1 loop /snap/amazon-ssm-agent/13009
loop1      7:1    0 28.4M  1 loop /snap/amazon-ssm-agent/13349
loop2      7:2    0   74M  1 loop /snap/core22/2411
loop3      7:3    0 49.3M  1 loop /snap/snapd/26865
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
xvdf     202:80   0    5G  0 disk

root@ip-172-31-11-100:~# fdisk /dev/xvdf

Welcome to fdisk (util-linux 2.39.3).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

The device contains 'ext4' signature and it will be removed by a write command. See fdisk(8) man page and --wipe option for more details.

Device does not contain a recognized partition table.
Created a new DOS (MBR) disklabel with disk identifier 0x653a631c.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-10485759, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-10485759, default 10485759): +3G

Created a new partition 1 of type 'Linux' and of size 3 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@ip-172-31-11-100:~# lsblk
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 28.2M  1 loop /snap/amazon-ssm-agent/13009
loop1      7:1    0 28.4M  1 loop /snap/amazon-ssm-agent/13349
loop2      7:2    0   74M  1 loop /snap/core22/2411
loop3      7:3    0 49.3M  1 loop /snap/snapd/26865
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
xvdf     202:80   0    5G  0 disk
└─xvdf1  202:81   0    3G  0 part

root@ip-172-31-11-100:~# fdisk xvdf

Welcome to fdisk (util-linux 2.39.3).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

fdisk: cannot open xvdf: No such file or directory
root@ip-172-31-11-100:~# fdisk /dev/xvdf

Welcome to fdisk (util-linux 2.39.3).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2):
First sector (6293504-10485759, default 6293504):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (6293504-10485759, default 10485759): +3G
Value out of range.
Last sector, +/-sectors or +/-size{K,M,G,T,P} (6293504-10485759, default 10485759): +2G
Value out of range.
Last sector, +/-sectors or +/-size{K,M,G,T,P} (6293504-10485759, default 10485759): +1.8G
Value out of range.
Last sector, +/-sectors or +/-size{K,M,G,T,P} (6293504-10485759, default 10485759): +1.5G

Created a new partition 2 of type 'Linux' and of size 1.5 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@ip-172-31-11-100:~# lsblk
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
loop0      7:0    0 28.2M  1 loop /snap/amazon-ssm-agent/13009
loop1      7:1    0 28.4M  1 loop /snap/amazon-ssm-agent/13349
loop2      7:2    0   74M  1 loop /snap/core22/2411
loop3      7:3    0 49.3M  1 loop /snap/snapd/26865
xvda     202:0    0    8G  0 disk
├─xvda1  202:1    0    7G  0 part /
├─xvda14 202:14   0    4M  0 part
├─xvda15 202:15   0  106M  0 part /boot/efi
└─xvda16 259:0    0  913M  0 part /boot
xvdf     202:80   0    5G  0 disk
├─xvdf1  202:81   0    3G  0 part
└─xvdf2  202:82   0  1.5G  0 part

 # Create a directory
root@ip-172-31-11-100:~# mkdir -p /mnt/my-vol-demo

root@ip-172-31-11-100:~# blkid /dev/xvdf
/dev/xvdf: PTUUID="653a631c" PTTYPE="dos"

root@ip-172-31-11-100:~# blkid /dev/xvdf1
/dev/xvdf1: PARTUUID="653a631c-01"

root@ip-172-31-11-100:~# blkid /dev/xvdf
/dev/xvdf: PTUUID="653a631c" PTTYPE="dos"

root@ip-172-31-11-100:~# blkid /dev/xvdf1
/dev/xvdf1: PARTUUID="653a631c-01"
root@ip-172-31-11-100:~#

# format the partition
root@ip-172-31-11-100:~# mkfs -t ext4 /dev/xvdf1
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 786432 4k blocks and 196608 inodes
Filesystem UUID: 8d8c8d69-826c-4670-8e3c-570514c452e1
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done

root@ip-172-31-11-100:~#

# mount the partition
mount /dev/xvdf1 /mnt/my-vol-demo

root@ip-172-31-11-100:~# mount /dev/xvdf1 /mnt/my-vol-demo
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
root@ip-172-31-11-100:~# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       6.8G  2.0G  4.8G  29% /
tmpfs           478M     0  478M   0% /dev/shm
tmpfs           191M  880K  191M   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/xvda16     881M   94M  726M  12% /boot
/dev/xvda15     105M  6.2M   99M   6% /boot/efi
tmpfs            96M   12K   96M   1% /run/user/1000
/dev/xvdf1      2.9G   24K  2.8G   1% /mnt/my-vol-demo

-----------
root@ip-172-31-11-100:~# blkid /dev/xvdf1
/dev/xvdf1: UUID="8d8c8d69-826c-4670-8e3c-570514c452e1" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="653a631c-01"
------------
# Make the fstab entry
root@ip-172-31-11-100:~# cat /etc/fstab
LABEL=cloudimg-rootfs   /        ext4   discard,commit=30,errors=remount-ro     0 1
LABEL=BOOT      /boot   ext4    defaults        0 2
LABEL=UEFI      /boot/efi       vfat    umask=0077      0 1
# UUID=3b301068-f136-45cd-8734-c21974a9b0c0  /mnt/demo-vol ext4 defaults,nofail 0 2
UUID=8d8c8d69-826c-4670-8e3c-570514c452e1 /mnt/my-vol-demo ext4 defaults,nofail 0 2

------------
# umount and mount it
root@ip-172-31-11-100:~# umount /mnt/my-vol-demo

root@ip-172-31-11-100:~# mount -a
root@ip-172-31-11-100:~# df -h /mnt/my-vol-demo/
Filesystem      Size  Used Avail Use% Mounted on
---------
# reboot and test it

root@ip-172-31-11-100:~# reboot

Broadcast message from root@ip-172-31-11-100 on pts/1 (Thu 2026-10-15 08:57:27 UTC):

The system will reboot now!

root@ip-172-31-11-100:~# client_loop: send disconnect: Broken pipe

---------

ubuntu@ip-172-31-11-100:~$ df -h /mnt/my-vol-demo/
Filesystem      Size  Used Avail Use% Mounted on
/dev/xvdf1      2.9G   24K  2.8G   1% /mnt/my-vol-demo
ubuntu@ip-172-31-11-100:~$ uptime
 09:00:48 up 3 min,  1 user,  load average: 0.07, 0.15, 0.07
```
