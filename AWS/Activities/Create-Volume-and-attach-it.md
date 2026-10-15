# AWS EC2: Attach, Format, Mount and Persist an EBS Volume in Linux

These notes cover how to identify an additional EBS volume, create an ext4 filesystem, mount it to a directory, troubleshoot a busy mount point, and configure automatic mounting after reboot.

**Note**: Make sure to create the volume in AWS , which should be in the same `AZ` as `EC2`. follow this [doc](https://github.com/SeshadriRC/ultimate-linux-guide/blob/main/My-Activities/Disk-management.md#volume-create)

## 1. Identify the attached disk

Command:

```
lsblk
```

Your output showed:

```
NAME     SIZE TYPE MOUNTPOINTS
xvda       8G disk
├─xvda1    7G part /
├─xvda14   4M part
├─xvda15 106M part /boot/efi
└─xvda16 913M part /boot
xvdf       5G disk
```

Explanation:

- `/dev/xvda` is your main EC2 disk, which contains the operating system and boot partitions.
- `/dev/xvdf` is the additional 5 GB disk you want to use for data.
- `MOUNTPOINTS` shows where a filesystem is currently accessible. Since `xvdf` has no mount point, it is not currently mounted.

The `lsblk` command helps identify disks, partitions, sizes, and mount points.

Important: Always identify the correct disk before formatting it. Formatting your root disk or a disk containing important data can cause data loss.

## 2. Create the mount-point directory

Command:

```
mkdir -p /mnt/demo-vol
```

Explanation:

- `mkdir` creates a directory.
- `-p` creates any missing parent directories and does not report an error if the directory already exists.
- `/mnt/demo-vol` is the directory where you want to access the new volume.

A mount point is simply a directory through which you access the contents of a mounted filesystem.

Creating the directory does not mount the disk.

## 3. Format the disk with the ext4 filesystem

Command:

```
mkfs -t ext4 /dev/xvdf
```

Explanation:

| Component   | Meaning                       |
| ----------- | ----------------------------- |
| `mkfs`      | Creates a filesystem          |
| `-t`        | Specifies the filesystem type |
| `ext4`      | The Linux filesystem type     |
| `/dev/xvdf` | The target disk               |

Your output included:

```
Filesystem UUID: 3b301068-f136-45cd-8734-c21974a9b0c0
Creating journal: done
Writing superblocks and filesystem accounting information: done
```

This confirms that the ext4 filesystem was created successfully.

The UUID (Universally Unique Identifier) identifies the filesystem and is useful for configuring persistent mounts.

Important: Formatting creates a new filesystem and can destroy access to existing data. Run `mkfs` only when you have confirmed that the disk is the correct one and can safely be formatted.

## 4. Mount the disk

Command:

```
mount /dev/xvdf /mnt/demo-vol
```

Explanation:

This makes the filesystem on `/dev/xvdf` accessible through `/mnt/demo-vol`.

Before mounting, the directory is just an ordinary directory on your root filesystem. After mounting, it provides access to the contents of the additional disk.

Verify the mount:

```
df -h /mnt/demo-vol/
```

Your output:

```
Filesystem  Size  Used Avail Use% Mounted on
/dev/xvdf   4.9G   24K  4.6G   1% /mnt/demo-vol
```

Meaning:

- `Filesystem`: The mounted device.
- `Size`: The usable filesystem capacity, approximately 4.9 GB.
- `Used`: Space already used.
- `Avail`: Space available for use.
- `Use%`: Percentage of space used.
- `Mounted on`: The directory where the filesystem is accessible.

The volume is now ready for storing files under `/mnt/demo-vol`.

## 5. Unmount the disk

Command:

```
umount /mnt/demo-vol
```

The `umount` command detaches a mounted filesystem from its mount point. It does not delete the filesystem or erase the files stored on the disk.

Your command returned:

```
umount: /mnt/demo-vol: target is busy.
```

### Why did this happen?

Linux considers a filesystem busy when a process is using it. Common reasons include:

- Your terminal is currently inside `/mnt/demo-vol` or one of its subdirectories.
- A process is reading or writing files on the volume.
- An application has files open on the volume.

### Recommended troubleshooting

First, move out of the mount point:

```
cd /
```

Then identify processes using the volume:

```
fuser -vm /mnt/demo-vol
```

Stop relevant processes safely, then retry:

```
umount /mnt/demo-vol
```

### The lazy unmount you used

Command:

```
umount -l /mnt/demo-vol
```

The `-l` option means lazy unmount. It detaches the mount from the filesystem hierarchy immediately, while existing references may remain until processes release them.

This can be useful in certain situations, but it does not guarantee that all processes have stopped accessing the filesystem. For normal maintenance, prefer identifying and stopping the processes first.

## 6. Configure automatic mounting using `/etc/fstab`

### Why is this required?

When you mount a disk manually:

```
mount /dev/xvdf /mnt/demo-vol
```

the mount configuration is not automatically saved for future boots. After a reboot, Linux may leave the volume unmounted.

To configure automatic mounting, add an entry to `/etc/fstab`.

### Step 6.1: View the current configuration

Command:

```
cat /etc/fstab
```

Your file contains:

```
LABEL=cloudimg-rootfs   /              ext4  discard,commit=30,errors=remount-ro  0 1
LABEL=BOOT              /boot          ext4  defaults                             0 2
LABEL=UEFI              /boot/efi      vfat  umask=0077                           0 1
UUID=3b301068-f136-45cd-8734-c21974a9b0c0 /mnt/demo-vol ext4 defaults,nofail 0 2
```

The first three entries configure your operating system's root and boot filesystems. The last entry is the one you added for your EBS volume.

### Step 6.2: Understand your new entry

```
UUID=3b301068-f136-45cd-8734-c21974a9b0c0 /mnt/demo-vol ext4 defaults,nofail 0 2
```

| Field                                       | Meaning                                                                                 |
| ------------------------------------------- | --------------------------------------------------------------------------------------- |
| `UUID=3b301068-f136-45cd-8734-c21974a9b0c0` | Identifies the filesystem on your EBS volume                                            |
| `/mnt/demo-vol`                             | Mount point                                                                             |
| `ext4`                                      | Filesystem type                                                                         |
| `defaults,nofail`                           | Standard mount options; `nofail` allows boot to continue if the volume is unavailable   |
| `0`                                         | Do not use the legacy `dump` backup utility for this filesystem                         |
| `2`                                         | Filesystem check order; check this filesystem after the root filesystem when applicable |

Why use UUID instead of `/dev/xvdf`?

Linux device names can vary depending on how disks are discovered. Using the filesystem UUID provides a more reliable way to identify the intended filesystem.

### Step 6.3: Back up the configuration before editing

```
cp /etc/fstab /etc/fstab.bak
```

Then edit the file:

```
nano /etc/fstab
```

Add the entry using your actual UUID, save the file, and exit.

## 7. Test the configuration without rebooting

Before restarting EC2, test the `/etc/fstab` configuration.

Run:

```
mount -a
```

What does `mount -a` do?

It attempts to mount all applicable filesystems listed in `/etc/fstab` that are not already mounted, except entries excluded by their options, such as `noauto`.

This lets you test your configuration without rebooting the instance.

Verify the result:

```
findmnt /mnt/demo-vol
```

Or:

```
df -hT /mnt/demo-vol
```

If the volume is already mounted, `mount -a` generally leaves that existing mount in place.

If an error occurs, investigate it before rebooting. The `nofail` option helps with boot continuity when a volume is unavailable, but it does not fix an incorrect mount configuration.

## 8. Verify automatic mounting after reboot

Once the configuration has been tested successfully, reboot your instance:

```
reboot
```

Reconnect to EC2 and execute:

```
findmnt /mnt/demo-vol
```

You can also run:

```
lsblk
df -hT
```

Confirm that the EBS volume is mounted at `/mnt/demo-vol` and has the expected filesystem type.

## 9. Complete workflow — commands for future reference

Here is the full sequence for a new, empty EBS volume.

Run formatting only once, after confirming the correct disk and that its contents can be erased.

```
# 1. Identify the attached disk
lsblk

# 2. Create the mount point
mkdir -p /mnt/demo-vol

# 3. Format the new disk (destructive)
mkfs -t ext4 /dev/xvdf

# 4. Mount the disk
mount /dev/xvdf /mnt/demo-vol

# 5. Verify the mount
df -hT /mnt/demo-vol

# 6. Get the filesystem UUID
blkid /dev/xvdf

# 7. Back up fstab
cp /etc/fstab /etc/fstab.bak

# 8. Edit fstab and add the UUID-based entry
nano /etc/fstab

# 9. Test the fstab configuration
mount -a

# 10. Verify the mount
findmnt /mnt/demo-vol

# 11. After a reboot, verify again
findmnt /mnt/demo-vol
```

## 10. Quick revision for DevOps interviews

| Concept        | Key point                                                         |
| -------------- | ----------------------------------------------------------------- |
| `lsblk`        | Lists disks and partitions                                        |
| `mkfs -t ext4` | Creates an ext4 filesystem                                        |
| `mkdir -p`     | Creates the mount-point directory                                 |
| `mount`        | Makes a filesystem accessible at a directory                      |
| `df -hT`       | Displays filesystem capacity and type                             |
| `umount`       | Detaches a filesystem                                             |
| `umount -l`    | Performs a lazy unmount                                           |
| `blkid`        | Displays filesystem identifiers, including UUIDs                  |
| `/etc/fstab`   | Stores filesystem mount configuration                             |
| `mount -a`     | Tests applicable `/etc/fstab` entries by attempting to mount them |
| `findmnt`      | Shows mounted filesystems and their mount points                  |

Interview answer: “When I attach an additional EBS volume to an EC2 Linux instance, I identify it using `lsblk`, create a filesystem with `mkfs`, mount it to a directory, and verify it using `df`. To make the mount persistent across reboots, I add the filesystem UUID to `/etc/fstab`, test the entry using `mount -a`, and verify it after reboot.”
