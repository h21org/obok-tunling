#!/bin/bash

# Define script version
SCRIPT_VERSION="v1.0"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   sleep 1
   exit 1
fi

# Function to press any key to continue
press_key(){
    read -p "Press any key to continue..."
}

# Define a function to colorize text
colorize() {
    local color="$1"
    local text="$2"
    local style="${3:-normal}"
    
    # Define ANSI color codes
    local black="\033[30m"
    local red="\033[31m"
    local green="\033[32m"
    local yellow="\033[33m"
    local blue="\033[34m"
    local magenta="\033[35m"
    local cyan="\033[36m"
    local white="\033[37m"
    local reset="\033[0m"
    
    # Define ANSI style codes
    local normal="\033[0m"
    local bold="\033[1m"
    local underline="\033[4m"
    # Select color code
    local color_code
    case $color in
        black) color_code=$black ;;
        red) color_code=$red ;;
        green) color_code=$green ;;
        yellow) color_code=$yellow ;;
        blue) color_code=$blue ;;
        magenta) color_code=$magenta ;;
        cyan) color_code=$cyan ;;
        white) color_code=$white ;;
        *) color_code=$reset ;;  # Default case, no color
    esac
    # Select style code
    local style_code
    case $style in
        bold) style_code=$bold ;;
        underline) style_code=$underline ;;
        normal | *) style_code=$normal ;;  # Default case, normal text
    esac

    # Print the colored and styled text
    echo -e "${style_code}${color_code}${text}${reset}"
}

# Function to download and extract Backhaul Core
download_and_extract() {
    local url="https://github.com/Musixal/Backhaul/releases/download/v0.6.5/backhaul_darwin_amd64.tar.gz"
    local dest_dir="/usr/local/bin"
    local temp_dir=$(mktemp -d)

    echo "Downloading Backhaul Core..."
    curl -L "$url" -o "$temp_dir/backhaul.tar.gz"

    echo "Extracting Backhaul Core..."
    tar -xzf "$temp_dir/backhaul.tar.gz" -C "$temp_dir"

    echo "Installing Backhaul Core..."
    mv "$temp_dir/backhaul" "$dest_dir/backhaul"
    chmod +x "$dest_dir/backhaul"

    echo "Backhaul Core installed successfully at $dest_dir/backhaul."
    rm -rf "$temp_dir"
}

# Function to configure a tunnel
configure_tunnel() {
    read -p "Enter the port to use for the tunnel: " tunnel_port
    read -p "Enter the transport type (tcp/ws): " transport

    cat << EOF > "/etc/backhaul_$tunnel_port.toml"
[server]
bind_addr = ":$tunnel_port"
transport = "$transport"
EOF

    echo "Configuration file created at /etc/backhaul_$tunnel_port.toml."
}

# Function to start a tunnel
start_tunnel() {
    read -p "Enter the port of the tunnel to start: " tunnel_port
    /usr/local/bin/backhaul -c "/etc/backhaul_$tunnel_port.toml" &
    echo "Tunnel started on port $tunnel_port."
}

# Function to display menu
display_menu() {
    clear
    echo -e "${cyan}Backhaul Management Script${reset}"
    echo "-------------------------------"
    echo "1. Download and Install Backhaul Core"
    echo "2. Configure a Tunnel"
    echo "3. Start a Tunnel"
    echo "4. Exit"
    echo "-------------------------------"
}

# Main script loop
while true; do
    display_menu
    read -p "Enter your choice [1-4]: " choice
    case $choice in
        1) download_and_extract ;;
        2) configure_tunnel ;;
        3) start_tunnel ;;
        4) exit 0 ;;
        *) echo "Invalid option!" && sleep 1 ;;
    esac
done
