# Linux Command Cheat Sheet

This is a concise cheat sheet of Linux commands used commonly in this homelab.

Filesystem & navigation
- `ls -al` — list files with details
- `cd /path/to/dir` — change directory
- `pwd` — print working directory
- `tree -L 2` — show directory tree (install `tree`)
- `find . -type f -name "*.log"` — find files

Disk & storage
- `df -h` — disk space usage
- `du -sh /path` — directory size
- `lsblk` — block devices
- `mount | column -t` — mounted filesystems

Processes & services
- `ps aux | grep process` — find processes
- `top` / `htop` — interactive process viewer
- `systemctl status svcname` — check systemd service
- `systemctl restart svcname` — restart service
- `journalctl -u svcname -f` — follow service logs

Networking
- `ip addr show` — list interfaces and addresses
- `ip route` — routing table
- `ss -tuln` — listening sockets
- `curl -I https://example.com` — check HTTP headers
- `ping -c 4 1.1.1.1` — ping host

Files & text
- `cat file`, `less file` — view files
- `grep -R "pattern" .` — search recursively
- `sed -n '1,100p' file` — print lines
- `awk '{print $1}' file` — field processing

Archive & transfer
- `tar cvzf name.tar.gz dir/` — create gzip tarball
- `tar xvf name.tar.gz` — extract
- `rsync -avz src/ dest/` — efficient copies
- `scp file user@host:/path` — secure copy

Git & repo
- `git status --porcelain` — script-friendly status
- `git add -A && git commit -m "msg"` — add & commit
- `git push -u origin master` — push and set upstream

Containers & virtualization (Proxmox/LXC)
- `pct list` — list LXC containers (Proxmox)
- `pct exec <vmid> -- bash` — run command inside container
- `qm list` — list QEMU VMs (Proxmox)
- `qm monitor <vmid>` — interact with VM monitor

Package management
- `apt update && apt upgrade` — Debian/Ubuntu update
- `apt install pkg` — install package

Permissions
- `chmod +x script.sh` — make executable
- `chown user:group file` — change owner

System checks
- `dmesg | tail` — kernel messages
- `free -h` — memory usage
- `uptime` — system uptime and load

Misc
- `date -R` — RFC2822 date
- `hostnamectl` — view/set hostname and OS info

Additions
- Let me know tools you use most (e.g., `pve`, `netify`, `influx` commands) and I'll expand this sheet.
