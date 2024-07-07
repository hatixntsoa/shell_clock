#!/bin/bash

# Function to get terminal size
get_terminal_size() {
	local width height
	width=$(tput cols)
	height=$(tput lines)
	echo "$width $height"
}

# Function to center text
center_text() {
	local text="$1"
	local width=$2
	local text_length=${#text}
	local padding=$((($width - $text_length) / 2))
	printf "%${padding}s%s\n" "" "$text"
}

# Function to handle interruption
cleanup() {
	echo -e && echo -e
	exit 0
}

# Function to check if figlet is installed
check_figlet() {
	if ! command -v figlet &>/dev/null; then
		echo "Please install figlet ..."
		# sudo echo
		# sudo apt install figlet -y
	fi
}

# Function to check if the ANSI Shadow font file exists
font_check() {
	if [ ! -f "/usr/share/figlet/ANSI Shadow.flf" ]; then
		echo "Please install ANSI Shadow figlet font..."
		# sudo echo
		sudo cp -rv "ANSI Shadow.flf" /usr/share/figlet
	fi
}

# Trap interrupt signal (SIGINT) and execute cleanup function
trap cleanup SIGINT

# Disable printing special characters when Ctrl+C is pressed
stty -echoctl

# Check if figlet is installed
check_figlet

# Check if the ANSI Shadow font file exists
font_check

# Main loop
while true; do
	# Get terminal size
	terminal_size=$(get_terminal_size)
	width=$(echo "$terminal_size" | cut -d' ' -f1)
	height=$(echo "$terminal_size" | cut -d' ' -f2)

	# Get centered time
	centered_time=$(date +'%H:%M:%S')
	centered_time=$(center_text "$centered_time" "$width")
	clear
	# Move cursor to the center of the terminal
	tput cup $((height / 3)) 0

	# Print centered time
	# echo -n "$centered_time"
	echo $(date +'%H : %M : %S') | figlet -f "ANSI Shadow" -c -t

	# Sleep for 1 second
	sleep 1
done
return 0
