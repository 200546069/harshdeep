#!/bin/bash

# Function to check if a package is installed
package_installed() {
    dpkg -l "$1" &>/dev/null
}

# Function to add user with ssh keys
add_user_with_ssh_keys() {
    username=$1
    ssh_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI $username@server1"
    home_dir="/home/$username"

    # Create user if not exists
    if ! id "$username" &>/dev/null; then
        useradd -m -s /bin/bash "$username"
        mkdir -p "$home_dir/.ssh"
        chmod 700 "$home_dir/.ssh"
        echo "$ssh_key" >> "$home_dir/.ssh/authorized_keys"
        chown -R "$username:$username" "$home_dir/.ssh"
        chmod 600 "$home_dir/.ssh/authorized_keys"
    fi
}

# Function to configure network interface
configure_network_interface() {
    cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s8:
      addresses: [192.168.16.21/24]
EOF
    netplan apply
}

# Function to update /etc/hosts
update_etc_hosts() {
    sed -i '/server1/d' /etc/hosts
    echo "192.168.16.21 server1" >> /etc/hosts
}

# Function to configure firewall
configure_firewall() {
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh comment 'SSH access on mgmt network' from 192.168.50.0/24 to any
    ufw allow http comment 'HTTP access on all interfaces'
    ufw allow 3128 comment 'Squid proxy on all interfaces'
    ufw --force enable
}

# Main script

# Check and install required packages
if ! package_installed apache2; then
    apt update
    apt install -y apache2
fi

if ! package_installed squid; then
    apt update
    apt install -y squid
fi

# Add users with ssh keys
add_user_with_ssh_keys "dennis" 
add_user_with_ssh_keys "aubrey" 
add_user_with_ssh_keys "captain"
add_user_with_ssh_keys "snibbles" 
add_user_with_ssh_keys "brownie" 
add_user_with_ssh_keys "scooter"
add_user_with_ssh_keys "sandy"
add_user_with_ssh_keys "perrier"
add_user_with_ssh_keys "cindy"
add_user_with_ssh_keys "tiger"
add_user_with_ssh_keys "yoda"
# dennis sudo user
usermod -aG sudo dennis


# Configure network interface
configure_network_interface

# Update /etc/hosts
update_etc_hosts

# Configure firewall
configure_firewall

echo "Configuration completed successfully."
