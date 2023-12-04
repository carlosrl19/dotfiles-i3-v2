#!/bin/sh

# Script to control the microphone volume, it limits the maximum volume to 60% (inc-vol) and the minimum volume (dec-vol) to 55%.

DEFAULT_SOURCE_INDEX=$(pacmd list-sources | grep "\* index:" | cut -d' ' -f5)

display_volume() {
	if [ -z "󰍮 $volume" ]; then
	  echo "No Mic Found"
	else
	  volume="󰍮 ${volume//[[:blank:]]/}" 
	  if [[ "$mute" == *"yes"* ]]; then
	    echo "󰍭 OFF"
	  elif [[ "$mute" == *"no"* ]]; then
	    echo "$volume"
	  else
	    echo "$volume !"
	  fi
	fi
}

case $1 in
	# Show volumen in polybar
	"show-vol")
		if [ -z "$2" ]; then
  			volume=$(pacmd list-sources | grep "index: $DEFAULT_SOURCE_INDEX" -A 7 | grep "volume" | awk -F/ '{print $2}')
  			mute=$(pacmd list-sources | grep "index: $DEFAULT_SOURCE_INDEX" -A 11 | grep "muted")
			display_volume
		else
  			volume=$(pacmd list-sources | grep "$2" -A 6 | grep "volume" | awk -F/ '{print $2}')
  			mute=$(pacmd list-sources | grep "$2" -A 11 | grep "muted" )
			display_volume
		fi
		;;
	# Increase volume
	"inc-vol")
	  if [ -z "$2" ]; then
		current_volume=$(pacmd list-sources | grep "index: $DEFAULT_SOURCE_INDEX" -A 7 | grep "volume" | awk -F/ '{print $2}' | cut -d'%' -f1)
		if [ "$current_volume" -le 55 ]; then
		  pactl set-source-volume $DEFAULT_SOURCE_INDEX +5%
		fi
	  else
		current_volume=$(pactl list-sources | grep "$2" -A 6 | grep "volume" | awk -F/ '{print $2}' | cut -d'%' -f1)
		if [ "$current_volume" -le 55 ]; then
		  pactl set-source-volume $2 +5%
		fi
	  fi
	  ;;
	  # Decrease volume
	"dec-vol")
	  if [ -z "$2" ]; then
		current_volume=$(pacmd list-sources | grep "index: $DEFAULT_SOURCE_INDEX" -A 7 | grep "volume" | awk -F/ '{print $2}' | cut -d'%' -f1)
		if [ "$current_volume" -ge 60 ]; then
		  pactl set-source-volume $DEFAULT_SOURCE_INDEX -5%
		fi
	  else
		current_volume=$(pactl list-sources | grep "$2" -A 6 | grep "volume" | awk -F/ '{print $2}' | cut -d'%' -f1)
		if [ "$current_volume" -ge 60 ]; then
		  pactl set-source-volume $2 -5%
		fi
	  fi
	  ;;
	  # Mute mic 
	"mute-vol")
		if [ -z "$2" ]; then
			pactl set-source-mute $DEFAULT_SOURCE_INDEX toggle
		else
			pactl set-source-mute $2 toggle
		fi
		;;
	*)
		echo "Invalid script option"
		;;
esac
