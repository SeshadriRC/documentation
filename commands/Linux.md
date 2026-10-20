# Linux Commands for DevOps Engineers

A comprehensive, production-tested Linux administration and troubleshooting reference for DevOps and SRE professionals.

---

## 1. System Information & Hardware Inspection

```bash
# Display Linux kernel version, architecture, and system details
uname -a

# Check Linux distribution and release details
cat /etc/os-release
lsb_release -a

# View system hostname, OS, kernel, and hardware architecture
hostnamectl

# System uptime, logged-in users, and load averages (1, 5, 15 min)
uptime

# Inspect CPU architecture, cores, threads, and clock speeds
lscpu

# View hardware topology and memory devices
sudo lshw -short
sudo dmidecode -t memory

# Check system time, time zone, and NTP synchronization
timedatectl
```

---

## 2. Resource Monitoring & Performance Triage (CPU & RAM)

```bash
# Real-time process and system resource monitor
top
htop

# Check memory utilization in human-readable units (RAM + Swap)
free -h -w

# Display virtual memory statistics every 2 seconds (5 samples)
# r: running, b: blocked, si/so: swap in/out, us/sy/id/wa: user/system/idle/iowait
vmstat 2 5

# Display per-CPU core utilization (requires sysstat package)
mpstat -P ALL 2 3

# Detailed memory breakdown (Cached, Buffers, Available, Slab)
cat /proc/meminfo | head -n 20

# Historical CPU utilization report
sar -u 2 5

# Historical Memory utilization report
sar -r 2 5

# Check if Linux Out-Of-Memory (OOM) killer recently killed any processes
dmesg -T | grep -i -E "oom|killed process"
sudo journalctl -k --grep="oom"
```

---

## 3. Disk, Filesystem & Volume Management (LVM & Storage)

```bash
# Check filesystem disk space and filesystem types (ext4, xfs, etc.)
df -hT

# Check inode usage (prevents "No space left on device" when disk has space but ran out of inodes)
df -i

# Identify the top 10 largest directories in the current folder
du -sh * 2>/dev/null | sort -hr | head -n 10

# Find files larger than 500MB
sudo find /var/log -type f -size +500M -exec ls -lh {} +

# List all block devices with partitions, mountpoints, and UUIDs
lsblk -f

# List disk partitions and disk geometry
sudo fdisk -l
sudo blkid

# Check currently mounted filesystems
findmnt
cat /etc/fstab

# Mount and unmount a filesystem
sudo mount /dev/xvdf /mnt/data
sudo umount /mnt/data

# Expand filesystem after resizing cloud disks (e.g. AWS EBS)
# For EXT4:
sudo resize2fs /dev/xvdf1
# For XFS:
sudo xfs_growfs /mnt/data

# LVM (Logical Volume Manager) administration
sudo pvs         # Physical volumes
sudo vgs         # Volume groups
sudo lvs         # Logical volumes
sudo lvextend -r -L +20G /dev/vg_name/lv_name   # Extend LV and resize underlying filesystem in one shot
```

---

## 4. Process Inspection & Management

```bash
# View all running processes with full command lines
ps aux

# Top 10 CPU-consuming processes
ps aux --sort=-%cpu | head -n 11

# Top 10 Memory-consuming processes
ps aux --sort=-%mem | head -n 11

# Search for process ID by name
pgrep -l nginx
pgrep -f "java.*my-app"

# Send graceful termination signal (SIGTERM - 15)
kill -15 <PID>

# Send forceful termination signal (SIGKILL - 9)
kill -9 <PID>

# Terminate processes matching a specific command pattern
pkill -f "celery worker"

# Find which process is locking or using a specific file/port
fuser -v 8080/tcp
fuser -v /var/log/syslog

# List all open files and network sockets opened by a specific process
lsof -p <PID>

# View process hierarchy tree
pstree -p
```

---

## 5. Networking & Troubleshooting

```bash
# Check details of applications listening on a specific port (e.g., Jaeger port 16686)
sudo ss -ltnp | grep 16686

# Display all listening TCP and UDP ports with program names and process IDs
sudo ss -tulpn

# Display connection summary statistics
ss -s

# Show IP addresses assigned to network interfaces
ip addr show
ip -br addr

# Show IP routing table and default gateway
ip route show

# Bring network interface up or down
sudo ip link set eth0 down
sudo ip link set eth0 up

# Test connectivity and measure packet loss
ping -c 4 8.8.8.8

# Trace network hop path and latency
traceroute google.com
mtr --report google.com

# DNS resolution troubleshooting
dig +short api.github.com
dig @8.8.8.8 mydomain.com ANY +trace
nslookup kubernetes.default.svc.cluster.local

# Test TCP port connectivity quickly without telnet
nc -zv 10.0.1.50 5432
curl -v telnet://10.0.1.50:5432

# HTTP endpoint inspection (headers only, follow redirects, measure time)
curl -I https://example.com
curl -s -w "\nHTTP Code: %{http_code}\nTotal Time: %{time_total}s\n" https://api.github.com -o /dev/null

# Capture network packets on eth0 for port 80/443 and save to pcap file
sudo tcpdump -i eth0 -nn -s0 -v "port 80 or port 443" -c 100 -w /tmp/traffic.pcap

# Read captured packets from a file
tcpdump -r /tmp/traffic.pcap -n

# UFW Firewall administration (Ubuntu / Debian)
sudo ufw status verbose
sudo ufw allow 22/tcp
sudo ufw allow from 10.0.0.0/16 to any port 6443 proto tcp
sudo ufw deny 8080

# IPTables quick inspection
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v
```

---

## 6. Systemd & Service Management

```bash
# Check service status and latest logs
sudo systemctl status nginx

# Start, stop, restart, and reload services
sudo systemctl start docker
sudo systemctl stop docker
sudo systemctl restart docker
sudo systemctl reload nginx

# Enable or disable service at boot time
sudo systemctl enable nginx
sudo systemctl disable apache2

# Reload systemd manager configuration after editing .service unit files
sudo systemctl daemon-reload

# List all failed systemd units
systemctl --failed

# Identify which services are slowing down system boot time
systemd-analyze
systemd-analyze blame
```

---

## 7. Log Analysis & Diagnostics

```bash
# Follow logs of a specific systemd service in real time (-f)
sudo journalctl -u nginx -f

# Follow service logs starting from the latest 100 lines
sudo journalctl -u docker -n 100 -f

# View logs for a service since a specific time window
sudo journalctl -u my-app --since "30 minutes ago"
sudo journalctl -u my-app --since "2026-10-18 09:00:00" --until "2026-10-18 10:00:00"

# View kernel logs with human-readable timestamps
sudo journalctl -k -e
dmesg -T | tail -n 50

# View priority errors, alerts, and emergencies only
sudo journalctl -p err..emerg -xb
```

---

## 8. Text Processing, Search & Pipelines

```bash
# Search recursively for case-insensitive keyword with line numbers
grep -rni "connection refused" /var/log/

# Search with extended regular expression matching multiple patterns
grep -E "ERROR|FATAL|EXCEPTION" app.log

# Invert match (filter out noise)
grep -v "DEBUG" app.log

# Extract specific columns from delimiter-separated output (e.g. IP from access log)
awk '{print $1, $7, $9}' /var/log/nginx/access.log | head -n 20

# Count unique HTTP status codes from access log
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c | sort -nr

# Find and replace text in-place in a file
sed -i 's/OLD_HOST/NEW_HOST/g' config.env

# Find files modified in the last 24 hours
find /var/log -type f -mtime -1

# Find files and execute commands safely with xargs
find /tmp/cache -type f -name "*.tmp" -print0 | xargs -0 rm -f

# Pipe output to both stdout and a log file simultaneously
./deploy.sh 2>&1 | tee deployment.log
```

---

## 9. User, Group & Permission Security

```bash
# Change permissions (Standard octal mode)
chmod 755 script.sh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Change owner and group recursively
sudo chown -R devops:devops /opt/my-app

# Create a new system user with bash shell and home directory
sudo useradd -m -s /bin/bash deployer

# Add user to secondary groups (e.g., docker, sudo)
sudo usermod -aG docker,sudo deployer

# Check user ID, primary group, and supplementary groups
id deployer

# Safely edit the sudoers file to grant passwordless permissions
sudo visudo
# Example rule inside visudo:
# deployer ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
```

---

## 10. SSH, File Transfers & Remote Operations

```bash
# Generate modern, secure Ed25519 SSH key pair
ssh-keygen -t ed25519 -C "devops@production"

# Copy SSH public key to remote server for passwordless login
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@192.168.1.100

# Connect using specific private key and custom port
ssh -i ~/.ssh/id_ed25519 -p 2222 user@192.168.1.100

# Local Port Forwarding: access remote database through an SSH bastion
# Forwards localhost:5433 -> remote-server -> db-internal.vpc:5432
ssh -N -L 5433:db-internal.vpc:5432 -i bastion.pem ec2-user@bastion-ip

# Efficient directory synchronization with rsync (archive, compress, verbose, progress)
rsync -avzP --delete /local/build/ user@remote:/var/www/html/

# Secure file copy (SCP)
scp -P 2222 app.jar user@remote:/opt/app/
```

---

## 11. Compression, Archives & Backups

```bash
# Create gzip-compressed tar archive (.tar.gz)
tar -czvf app-backup-$(date +%F).tar.gz /var/www/app

# Extract tar.gz archive to current directory
tar -xzvf app-backup.tar.gz

# Extract tar.gz archive to a specific directory
tar -xzvf app-backup.tar.gz -C /opt/destination/

# List contents of a tar archive without extracting
tar -tzvf app-backup.tar.gz
```

---

## 12. Cron, Automation & Terminal Multiplexing

```bash
# Edit current user's cron jobs
crontab -e

# List scheduled cron jobs
crontab -l

# Run long script detached from terminal session (survives logout)
nohup ./long-migration.sh > migration.log 2>&1 &

# Inspect background jobs in current shell session
jobs -l

# Tmux terminal multiplexer
tmux new -s devops-session       # Start new session
tmux attach -t devops-session    # Reattach to session
# Detach shortcut inside tmux: Ctrl+B then D
```

---

## 13. Shell Configuration & Aliases (WSL / Ubuntu Navigation)

### Option 1: Create an alias (recommended)

**Step 1:** Open your Ubuntu terminal and run:
```bash
nano ~/.bashrc
```

**Step 2:** Go to the bottom and add:
```bash
alias projects='cd /mnt/c/Myfolder/MyProjects/'
```

**Step 3:** Save and exit:
- `Ctrl + O` → `Enter` (save)
- `Ctrl + X` (exit)

**Step 4:** Apply the change:
```bash
source ~/.bashrc
```

**Step 5:** Test it:
```bash
projects
```

That's it! Your terminal will navigate directly to:
```
/mnt/c/Myfolder/MyProjects/
```

