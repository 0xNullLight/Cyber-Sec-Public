#!/bin/bash

# Set output directory for collected forensic data
output_dir="forensic_output"
mkdir -p "$output_dir"

# ------------------------ 1. Last Login Information ------------------------
echo "Last login information:" >> "$output_dir/last_logins.txt"
last >> "$output_dir/last_logins.txt"
lastlog >> "$output_dir/lastlogins.txt"

# ------------------------ 2. Crontab Jobs ------------------------
echo "Crontab jobs:" >> "$output_dir/crontab_jobs.txt"
crontab -l >> "$output_dir/crontab_jobs.txt" 2>/dev/null
ls /var/spool/cron/crontabs/ >> "$output_dir/crontab_jobs.txt"

# ------------------------ 3. System Logs ------------------------
echo "System logs:" >> "$output_dir/system_logs.txt"
cat /var/log/auth.log >> "$output_dir/system_logs.txt" 2>/dev/null
cat /var/log/syslog >> "$output_dir/system_logs.txt" 2>/dev/null
cat /var/log/messages >> "$output_dir/system_logs.txt" 2>/dev/null
dmesg >> "$output_dir/system_logs.txt"

# ------------------------ 4. Security Audit Logs ------------------------
echo "Audit logs:" >> "$output_dir/audit_logs.txt"
ausearch -m avc -ts recent >> "$output_dir/audit_logs.txt" 2>/dev/null

# ------------------------ 5. Loaded Kernel Modules ------------------------
echo "Loaded Kernel Modules:" >> "$output_dir/kernel_modules.txt"
lsmod >> "$output_dir/kernel_modules.txt"

# ------------------------ 6. Environment Variables ------------------------
echo "Environment Variables:" >> "$output_dir/environment_variables.txt"
printenv >> "$output_dir/environment_variables.txt"

# ------------------------ 7. Firewall Configuration ------------------------
echo "Firewall Configuration:" >> "$output_dir/firewall_rules.txt"
iptables -L >> "$output_dir/firewall_rules.txt"
ufw status >> "$output_dir/firewall_rules.txt" 2>/dev/null

# ------------------------ 8. Sudoers File ------------------------
echo "Sudoers File:" >> "$output_dir/sudoers_file.txt"
cat /etc/sudoers >> "$output_dir/sudoers_file.txt" 2>/dev/null

# ------------------------ 9. Suspicious Files in Home Directories ------------------------
echo "Suspicious files in home directories:" >> "$output_dir/suspicious_home_files.txt"
find /home -type f -name '.*' -exec ls -l {} \; >> "$output_dir/suspicious_home_files.txt"

# ------------------------ 10. File System Check ------------------------
echo "File System Integrity Check:" >> "$output_dir/fs_check.txt"
fsck -A >> "$output_dir/fs_check.txt" 2>/dev/null

# ------------------------ 11. User and Group Audit ------------------------
echo "User and Group Audit:" >> "$output_dir/user_group_audit.txt"
cat /etc/passwd >> "$output_dir/user_group_audit.txt"
cat /etc/group >> "$output_dir/user_group_audit.txt"

# ------------------------ 12. Suspicious Network Connections ------------------------
echo "Suspicious Network Connections:" >> "$output_dir/suspicious_connections.txt"
netstat -tuln >> "$output_dir/suspicious_connections.txt"

# ------------------------ 13. Shadow File ------------------------
echo "Shadow File:" >> "$output_dir/shadow_file.txt"
cat /etc/shadow >> "$output_dir/shadow_file.txt"

# ------------------------ 14. System Info ------------------------
echo "System Info:" >> "$output_dir/system_info.txt"
hostname >> "$output_dir/system_info.txt"
uname -a >> "$output_dir/system_info.txt"
lsblk >> "$output_dir/system_info.txt"
df -h >> "$output_dir/system_info.txt"

# ------------------------ 15. User Information ------------------------
echo "User Information:" >> "$output_dir/user_info.txt"
who >> "$output_dir/user_info.txt"
getent passwd >> "$output_dir/user_info.txt"

# ------------------------ 16. Installed Packages ------------------------
echo "Installed Packages:" >> "$output_dir/installed_packages.txt"

# Check for Debian/Ubuntu-based systems
if command -v dpkg &>/dev/null; then
    dpkg-query -l >> "$output_dir/installed_packages.txt"
# Check for Red Hat/CentOS/Fedora-based systems
elif command -v rpm &>/dev/null; then
    rpm -qa >> "$output_dir/installed_packages.txt"
elif command -v dnf &>/dev/null; then
    dnf list installed >> "$output_dir/installed_packages.txt"
elif command -v yum &>/dev/null; then
    yum list installed >> "$output_dir/installed_packages.txt"
else
    echo "No package manager found!" >> "$output_dir/installed_packages.txt"
fi

# ------------------------ End of Script ------------------------

echo "Forensic data collection completed! All files are saved in: $output_dir"
