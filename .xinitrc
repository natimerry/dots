/usr/bin/gentoo-pipewire-launcher &
exec dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) bspwm 
