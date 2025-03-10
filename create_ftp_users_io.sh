#!/bin/bash

# Define FTP directory
FTP_DIR="/mnt/files"

# Prompt for password hash
read -p "Enter the password hash for FTP users: " PASSWORD_HASH

# Prompt for usernames
echo "Enter FTP usernames one by one. Type 'done' when finished:"
FTP_USERS=()
while true; do
    read -p "Enter username: " USERNAME
    if [[ "$USERNAME" == "done" ]]; then
        break
    fi
    FTP_USERS+=("$USERNAME")
done

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
