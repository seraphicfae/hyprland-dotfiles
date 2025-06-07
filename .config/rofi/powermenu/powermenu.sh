#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x

# Current Theme
theme="$HOME/.config/rofi/powermenu/powermenu.rasi"

# CMDs
uptime=$(uptime -p | sed 's/up //')
host=$(hostname)

# Options
lock=''
suspend=''
logout='󰍃'
reboot=''
shutdown=' '
yes=''
no=''

# Rofi CMD
rofi_cmd() {
	rofi -dmenu -p "Uptime: $uptime" -mesg "Uptime: $uptime" -theme "$theme"
}

# Confirmation CMD
confirm_cmd() {
	rofi -dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1;}' \
		-theme-str 'element-text {horizontal-align: 0.5;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-theme "$theme"
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	[[ $(confirm_exit) == "$yes" ]] || exit 0
	case "$1" in
		--shutdown) systemctl poweroff ;;
		--reboot) systemctl reboot ;;
		--suspend)
			mpc -q pause
			amixer set Master mute
			systemctl suspend
			;;
		--logout) hyprctl dispatch exit ;;
	esac
}

# Actions
case "$(run_rofi)" in
	$shutdown) 
	run_cmd --shutdown 
	;;
	$reboot) 
	run_cmd --reboot 
	;;
	$lock)
		playerctl pause
		hyprlock
		;;
	$suspend) 
	run_cmd --suspend 
	;;
	$logout) 
	run_cmd --logout 
	;;
esac