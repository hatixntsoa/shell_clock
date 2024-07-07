#!/bin/bash

# Function to get terminal size
function get_terminal_size() {
	local width height
	width=$(tput cols)
	height=$(tput lines)
	echo "$width $height"
}

# Function to center text
function center_text() {
	local text="$1"
	local width=$2
	local text_length=${#text}
	local padding=$((($width - $text_length) / 2))
	printf "%${padding}s%s\n" "" "$text"
}

# Function to handle interruption
function cleanup() {
	echo -e && echo -e
	exit 0
}

# Function to install figlet
function install_figlet() {
	echo "Installing figlet..."

	if command -v apt-get &>/dev/null; then
		$SUDO apt-get update
		$SUDO apt-get install -y figlet
	elif command -v yum &>/dev/null; then
		$SUDO yum install -y figlet
	elif command -v dnf &>/dev/null; then
		$SUDO dnf install -y figlet
	elif command -v pacman &>/dev/null; then
		$SUDO pacman -S --noconfirm figlet
	elif command -v zypper &>/dev/null; then
		$SUDO zypper install -y figlet
	else
		echo "No supported package manager found. Please install figlet manually."
		exit 1
	fi
}

# Function to check if figlet is installed
function check_figlet() {
	if ! command -v figlet &>/dev/null; then
		install_figlet
		if ! command -v figlet &>/dev/null; then
			echo "figlet installation failed. Please install it manually."
			sleep 3
			exit 1
		fi
		sleep 3
	fi
}

# Function to check if the ANSI Shadow font file exists
function font_check() {
	local figlet_fonts=$(
		whereis figlet |
			grep -o '/[^ ]*/share' |
			sed 's/$/\/figlet/' |
			head -n 1
	)
	if [ ! -f "$figlet_fonts/ANSI Shadow.flf" ]; then
		echo "Installing ANSI Shadow figlet font..."
		$SUDO cp -rv "font/ANSI Shadow.flf" "$figlet_fonts"
		if [ $? -eq 0 ]; then
			echo "Font installed successfully."
		else
			echo "Failed to install font. Please check permissions or install manually."
			exit 1
		fi
		sleep 3
	fi
}

# Check if the script is running on Android
if [ -f "/system/build.prop" ]; then
	SUDO=""
else
	# Check for sudo availability on other Unix-like systems
	if command -v sudo &>/dev/null; then
		SUDO="sudo"
	else
		echo "Sorry, sudo is not available. Please run this script as root or with sudo."
		exit 1
	fi
fi

# Trap interrupt signal (SIGINT) and execute cleanup function
trap cleanup SIGINT

# Disable printing special characters when Ctrl+C is pressed
stty -echoctl

# Here to init sudo if needed
$SUDO echo

# Check if figlet is installed
check_figlet

# Check if the ANSI Shadow font file exists
font_check

# Main loop
while true; do
	# Don't apply center method on termux
	if [ ! -f "/system/build.prop" ]; then
		# Get terminal size
		terminal_size=$(get_terminal_size)
		width=$(echo "$terminal_size" | cut -d' ' -f1)
		height=$(echo "$terminal_size" | cut -d' ' -f2)

		# Get centered time
		centered_time=$(date +'%H:%M:%S')
		centered_time=$(center_text "$centered_time" "$width")
		clear

		# Move cursor to the center of the terminal
		# except for termux
		tput cup $((height / 3)) 0
	else
		clear
		echo -e && echo -e && echo -e
	fi

	# Print centered time
	echo $(date +'%H : %M : %S') | figlet -f "ANSI Shadow" -c -t

	# Sleep for 1 second
	sleep 1
done

return 0
