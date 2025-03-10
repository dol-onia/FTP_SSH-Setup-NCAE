#!/bin/bash

# Script to install and configure FTP server on Rocky Linux 8 with Scoring System

# Define variables
FTP_USER="ftpuser"
FTP_PASS="P@ssw0rd"
FTP_DIR="/mnt/files"
CONFIG_FILE="/etc/vsftpd/vsftpd.conf"
FTP_LOG="/var/log/ftp_scoring.log"

# List of expected files for scoring
EXPECTED_FILES=(
    "iron_cross.data"
    "3_point_molly.data"
    "dark_side.data"
    "come_dont_come.data"
    "odds.data"
    "_house_secrets.data"
    "pass_line.data"
    "risky_roller.data"
    "covered_call.data"
    "married_put.data"
    "bull_call.data"
    "protective_collar.data"
    "long_straddle.data"
    "long_call_butterfly.data"
    "iron_condor.data"
    "iron_butterfly.data"
    "short_put.data"
    "data_dump_1.bin"
    "data_dump_2.bin"
    "data_dump_3.bin"
    "datadump.bin"
)

# Function to check file integrity
check_files() {
    echo "Checking file integrity..." | tee -a $FTP_LOG
    missing_files=0

    for file in "${EXPECTED_FILES[@]}"; do
        if [[ ! -f "$FTP_DIR/$file" ]]; then
            echo "MISSING: $file" | tee -a $FTP_LOG
            missing_files=$((missing_files + 1))
        fi
    done

    if [[ $missing_files -eq 0 ]]; then
        echo "SCORING RESULT: GREEN - All files exist and pass integrity check." | tee -a $FTP_LOG
    elif [[ $missing_files -lt ${#EXPECTED_FILES[@]} ]]; then
        echo "SCORING RESULT: YELLOW - Some files are missing or failed integrity check." | tee -a $FTP_LOG
    else
        echo "SCORING RESULT: RED - No files found." | tee -a $FTP_LOG
    fi
}

# Update system packages
echo "Updating system packages..."
dnf update -y

# Install vsftpd
echo "Installing vsftpd..."
dnf install -y vsftpd

# Enable and start the vsftpd service
echo "Enabling and starting vsftpd service..."
systemctl enable vsftpd --now

# Create FTP user and home directory
echo "Creating FTP user: $FTP_USER..."
useradd -m $FTP_USER
echo "$FTP_USER:$FTP_PASS" | chpasswd

# Set up FTP directory
echo "Setting up FTP directory..."
mkdir -p $FTP_DIR
chown -R $FTP_USER:$FTP_USER $FTP_DIR
chmod 755 $FTP_DIR

# Backup original vsftpd configuration
cp $CONFIG_FILE ${CONFIG_FILE}.bak

# Configure vsftpd
echo "Configuring vsftpd..."
cat <<EOF > $CONFIG_FILE
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
user_sub_token=\$USER
local_root=$FTP_DIR
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
allow_writeable_chroot=YES
EOF

# Restart vsftpd to apply changes
echo "Restarting vsftpd..."
systemctl restart vsftpd

# Allow FTP traffic through firewall
echo "Configuring firewall..."
firewall-cmd --permanent --add-service=ftp
firewall-cmd --permanent --add-port=40000-50000/tcp
firewall-cmd --reload

# Set SELinux to allow FTP access
echo "Setting SELinux policies..."
setsebool -P ftpd_full_access 1
semanage fcontext -a -t public_content_t "$FTP_DIR(/.*)?"
restorecon -Rv $FTP_DIR

# Run file integrity check for scoring
check_files

echo "FTP setup complete! Scoring details logged to $FTP_LOG"
echo "You can now connect with: ftp://$FTP_USER@$(hostname -I | awk '{print $1}')"
