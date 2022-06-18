#!bin/sh

#hotkey daemon
sxhkd &

autorandr --change primary


picom --experimental-backend &
dunst &
sh ~/.config/polybar/launch.sh

# network manager applet
nm-applet &

#sound breh
pipewire &

# wallpaper
nitrogen --restore &
udiskie &
# policy kit
if [[ ! `pidof xfce-polkit` ]]; then
	/usr/lib/xfce-polkit/xfce-polkit &
fi

#hide borders of inactive windows
if ["$(ps aux | grep -o ".config/bspwm/hideborder.sh")" != ""]
then
	echo "RUN"
else
	sh .config/bspwm/hideborder.sh &
fi
discord --start-minimized &
