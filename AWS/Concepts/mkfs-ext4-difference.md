`fdisk` is a Linux command used to create, view, modify, and delete disk partitions.

In your AWS EC2 example, you used `/dev/xvdf` (5 GB) and formatted the entire disk directly using `mkfs`. `fdisk` is useful when you want to divide that disk into one or more partitions before formatting them.

## 1. Difference between `fdisk` and `mkfs`

`fdisk` — Partition the disk

Creates partitions such as `/dev/xvdf1` and `/dev/xvdf2` on a disk.

`mkfs` — Create a filesystem

Formats a disk or partition with a filesystem such as ext4.

`mount` — Access the filesystem

Makes the filesystem accessible through a directory such as `/mnt/demo-vol`.

## 2. Example using your 5 GB EBS volume

Suppose you want to create two partitions on `/dev/xvdf`.

EBS disk: `/dev/xvdf`

## 5 GB

`/dev/xvdf1`

### 3 GB

Application data

`/dev/xvdf2`

### 2 GB

Log data

Here is the workflow:

### Step 1: View the disk

```
lsblk
```

### Step 2: Open the partitioning utility

```
fdisk /dev/xvdf
```

Inside `fdisk`, common commands are:

| Input | Purpose                             |
| ----- | ----------------------------------- |
| `p`   | Print the partition table           |
| `n`   | Create a new partition              |
| `d`   | Delete a partition                  |
| `w`   | Write changes and exit              |
| `q`   | Quit without saving pending changes |

For example, `n` starts creating a new partition. Follow the prompts to select its partition number and size.

Warning: Writing partition-table changes can affect existing data. Do not experiment with `fdisk` on a disk containing data you need to preserve.

### Step 3: Verify the partitions

After saving the partition table:

```
lsblk
```

You may see:

```
xvdf    5G disk
├─xvdf1 3G part
└─xvdf2 2G part
```

The exact sizes depend on the partition sizes you selected.

### Step 4: Format each partition

```
mkfs -t ext4 /dev/xvdf1
mkfs -t ext4 /dev/xvdf2
```

Each partition now has its own ext4 filesystem.

### Step 5: Mount each partition

```
mkdir -p /mnt/app-data /mnt/log-data

mount /dev/xvdf1 /mnt/app-data
mount /dev/xvdf2 /mnt/log-data
```

Verify:

```
df -hT
```

## 3. Do you always need `fdisk`?

No. You have two common options.

| Requirement                                | Workflow                                     |
| ------------------------------------------ | -------------------------------------------- |
| Use the entire 5 GB disk as one filesystem | `mkfs` directly on `/dev/xvdf`, then `mount` |
| Divide the disk into multiple partitions   | `fdisk` → `mkfs` on each partition → `mount` |

For modern Linux systems, other partitioning tools such as `parted` and `gdisk` are also available, depending on the partition-table format and requirements.

Remember this sequence:

`fdisk` → `mkfs` → `mount` → `/etc/fstab`

Use `fdisk` only if partitioning is required. In your earlier lab, formatting `/dev/xvdf` directly was sufficient because you wanted to use the whole volume as a single filesystem.
