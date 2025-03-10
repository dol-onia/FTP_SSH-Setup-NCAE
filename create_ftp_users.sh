#!/bin/bash

# Define FTP directory
FTP_DIR="/mnt/files"

# Define FTP password hash (replace with the provided hash)
PASSWORD_HASH='$6$KHk2hJlrIZKWxWA9$z2OrpVg05wxoUp/BL12VY9rvxvgyZhta.qKf9SwckeNMcW4QvCJACSA4QyBwy88UpPAGDrskbu7rb7sh8fbnM1'

# List of FTP users (extracted from the image)
FTP_USERS=(
  "camille_jenatzy"
  "gaston_chasseloup"
  "leon_serpollet"
  "william_vanderbilt"
  "henri_fournier"
  "maurice_augieres"
  "arthur_duray"
  "henry_ford"
  "louis_rigolly"
  "pierre_caters"
  "paul_baras"
  "victor_hemery"
  "fred_marriott"
  "lydston_hornsted"
  "kenelm_guinness"
  "rene_thomas"
  "ernest_eldridge"
  "malcolm_campbell"
  "ray_keech"
  "john_cobb"
  "dorothy_levitt"
  "paula_murphy"
  "betty_skelton"
  "rachel_kushner"
  "kitty_oneil"
  "jessi_combs"
  "andy_green"
)

# Ensure the FTP directory exists
mkdir -p "$FTP_DIR"
chmod 755 "$FTP_DIR"

# Create users
echo "Creating FTP users..."
for USER in "${FTP_USERS[@]}"; do
    # Create user with no shell access
    useradd -m -d "$FTP_DIR/$USER" -s /sbin/nologin "$USER"

    # Set the password hash
    usermod --password "$PASSWORD_HASH" "$USER"

    # Set permissions for user's FTP directory
    mkdir -p "$FTP_DIR/$USER"
    chown -R "$USER:$USER" "$FTP_DIR/$USER"
    chmod 750 "$FTP_DIR/$USER"

    echo "Created user: $USER"
done

# Restrict users to their home directories
echo "Configuring FTP access restrictions..."
echo -e "\n# Restrict FTP users" >> /etc/vsftpd/user_list
for USER in "${FTP_USERS[@]}"; do
    echo "$USER" >> /etc/vsftpd/user_list
done

echo "All FTP users created successfully!"
