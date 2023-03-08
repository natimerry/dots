#!/bin/sh

function get_vol(){
	echo "vol:$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1)"
}

function vol_up(){
  pactl set-sink-volume $(pactl info | grep alsa_output | sed -r 's/^Default Sink: //') +5%
}


function vol_down(){
	pactl set-sink-volume $(pactl info | grep alsa_output | sed -r 's/^Default Sink: //') -5%
}
if [ $1 = 'list' ]; then
	get_vol

elif [ $1 = 'up' ]; then
	vol_up

elif [ $1 = 'down' ]; then
	vol_down

elif [ $1 = 'mute' ]; then
	pactl set-sink-mute $(pactl info | grep alsa_output | sed -r 's/^Default Sink: //') toggle
fi