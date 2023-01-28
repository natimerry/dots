#!bin/sh
source ~/.zsh_plugs/funcs.zsh 
#hotkey daemon
sxhkd &
autorandr --change primary
picom &
dunst &
sh ~/.config/polybar/launch.sh

# network manager applet
nm-applet &
feh --bg /home/nolife/wallpapers/raindrops-1_FHD.jpg
#sound breh
#pipewire &

# wallpaper
#nitrogen --restore &
#udiskie &
# policy kit
if [[ ! `pidof xfce-polkit` ]]; then
	/usr/libexec/xfce-polkit &
fi

#hide borders of inactive windows
if ["$(ps aux | grep -o ".config/bspwm/hideborder.sh")" != ""]
then
	echo "RUN"
else
	sh .config/bspwm/hideborder.sh &
fi
#udiskie &
#pywal &
#nm-applet &
