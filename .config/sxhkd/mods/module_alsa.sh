#!/usr/bin/env bash

VOL="$(amixer -D pulse sget Master | tail -n 1 | cut -c 32-35)"
STAT0="$(amixer -D pulse sget Master | tail -n 1 | cut -c 38)"
STAT1="$(amixer -D pulse sget Master | tail -n 1 | cut -c 35)"
STAT2="$(amixer -D pulse sget Master | tail -n 1 | cut -c 40)"
UPORDOWN="$1"

if [ "$UPORDOWN" = "up" ]
then
	if [ "$STAT0" = "f" ] || [ "$STAT1" = "f" ] || [ "$STAT2" = "f" ]
	then
		notify-send -u critical "Volume Manager" "Unmuted\!"
		pactl set-sink-mute 1 0
	fi
	amixer -D pulse sset Master 10%+
fi

if [ "$UPORDOWN" = "down" ]
then

	# the commented out part below should work
	# but for some reason
	# decreasing 10% volume shows 9% volume decrease in polybar widget
	# but it is actually 10% volume decrease when checking with amixer
	# so less efficient code; for the OCD;
	#if [ "$VOL" = "100%" ]
	#then
	#	amixer -D pulse sset Master 90%
	#else
	#	amixer -D pulse sset Master 10%-
	#fi

	case "$VOL" in

		"100%")
		amixer -D pulse sset Master 90%
		;;

		"90%]")
		amixer -D pulse sset Master 80%
		;;

		"80%]")
		amixer -D pulse sset Master 70%
		;;

		"70%]")
		amixer -D pulse sset Master 60%
		;;

		"60%]")
		amixer -D pulse sset Master 50%
		;;

		"50%]")
		amixer -D pulse sset Master 40%
		;;

		"40%]")
		amixer -D pulse sset Master 30%
		;;

		"30%]")
		amixer -D pulse sset Master 20%
		;;

		"20%]")
		amixer -D pulse sset Master 10%
		;;

		"0%] ")
		amixer -D pulse sset Master 10%-
		;;

	esac

fi
