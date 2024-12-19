#!/bin/bash

# Define script version
SCRIPT_VERSION="v0.3"

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   sleep 1
   exit 1
fi

# just press key to continue
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

# Function to check for required tools
install_tool() {
    local tool=$1
    local package=$2
    if ! command -v "$tool" &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            echo "Installing $tool..."
            sleep 1
            apt-get update
            apt-get install -y "$package"
        else
            echo "Error: Unsupported package manager. Please install $tool manually."
            press_key
            exit 1
        fi
    fi
}

# Install required tools
install_tool unzip unzip
install_tool jq jq

# Function to display server info
display_server_info() {
    local SERVER_IP=$(hostname -I | awk '{print $1}')
    local SERVER_COUNTRY=$(curl -sS "http://ipwhois.app/json/$SERVER_IP" | jq -r '.country')
    local SERVER_ISP=$(curl -sS "http://ipwhois.app/json/$SERVER_IP" | jq -r '.isp')

    echo -e "\e[93m═══════════════════════════════════════════\e[0m"
    echo -e "${cyan}IP Address:${reset} $SERVER_IP"
    echo -e "${cyan}Location:${reset} $SERVER_COUNTRY"
    echo -e "${cyan}Datacenter:${reset} $SERVER_ISP"
    echo -e "\e[93m═══════════════════════════════════════════\e[0m"
}

# Function to optimize network settings
optimize_network() {
    echo "Optimizing network settings..."
    sysctl -w net.core.rmem_max=33554432
    sysctl -w net.core.wmem_max=33554432
    sysctl -w net.ipv4.tcp_rmem="10240 87380 33554432"
    sysctl -w net.ipv4.tcp_wmem="10240 87380 33554432"
    sysctl -w net.ipv4.tcp_congestion_control=bbr
    echo "Network optimization complete."
}

# Function to display menu
display_menu() {
    clear
    echo -e "${cyan}Simple Network Script${reset}"
    echo "-------------------------------"
    display_server_info
    echo "1. Optimize network settings"
    echo "2. Exit"
    echo "-------------------------------"
}

# Main script
while true; do
    display_menu
    read -p "Enter your choice [1-2]: " choice
    case $choice in
        1) optimize_network ;;
        2) exit 0 ;;
        *) echo "Invalid option!" && sleep 1 ;;
    esac
done
