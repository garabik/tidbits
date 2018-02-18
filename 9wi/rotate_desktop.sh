#!/bin/bash
#
# rotate_desktop.sh
#
# Rotates modern Linux desktop screen and input devices to match. Handy for
# convertible notebooks. Call this script from panel launchers, keyboard
# shortcuts, or touch gesture bindings (xSwipe, touchegg, etc.).
#
# Using transformation matrix bits taken from:
#   https://wiki.ubuntu.com/X/InputCoordinateTransformation
#
# based on https://gist.github.com/mildmojo/48e9025070a2ba40795c
# tuned for UMAX Visionbook 9wi pro


# usage: rotate_desktop.sh [rotation]
# where rotation is one of left, right, normal, inverted
# without arguments, switch between normal/right or inverted/left


# Configure these to match your hardware (names taken from `xinput` output).
TOUCHPAD='pointer:HS-M962-CS-A3-19-00 USB KEYBOARD'
TOUCHSCREEN='FTSC0001:00 2808:1015'

if [ "$1" = '-h' ]; then
  echo "Usage: $0 [normal|inverted|left|right]"
  echo
  exit 1
fi

# where to keep last rotation status
# use /tmp only on single user machines, otherwise use something like ~/.cache/.umax-last-rot
LAST_ROT_FILE=/tmp/.umax-last-rot-$(id -u)

function do_rotate
{
  xrandr --output $1 --rotate $2

  TRANSFORM='Coordinate Transformation Matrix'

  case "$2" in
    normal)
      [ ! -z "$TOUCHPAD" ]    && xinput set-prop "$TOUCHPAD"    "$TRANSFORM"  0 -1  1  1  0 0 0 0 1 || true
      [ ! -z "$TOUCHSCREEN" ] && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM"  1  0  0  0  1 0 0 0 1
      ;;
    inverted)
      [ ! -z "$TOUCHPAD" ]    && xinput set-prop "$TOUCHPAD"    "$TRANSFORM"  0  1  0 -1  0 1 0 0 1 || true
      [ ! -z "$TOUCHSCREEN" ] && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM" -1  0  1  0 -1 1 0 0 1
      ;;
    left)
      [ ! -z "$TOUCHPAD" ]    && xinput set-prop "$TOUCHPAD"    "$TRANSFORM" -1  0  1  0 -1 1 0 0 1 || true
      [ ! -z "$TOUCHSCREEN" ] && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM"  0 -1  1  1  0 0 0 0 1
      ;;
    right)
      [ ! -z "$TOUCHPAD" ]    && xinput set-prop "$TOUCHPAD"    "$TRANSFORM"  1  0  0  0  1 0 0 0 1 || true
      [ ! -z "$TOUCHSCREEN" ] && xinput set-prop "$TOUCHSCREEN" "$TRANSFORM"  0  1  0 -1  0 1 0 0 1
      ;;
  esac
}

XDISPLAY=`xrandr --current | grep ' connected' | head -1 | sed -e 's/ .*//g'`

echo Detected display $XDISPLAY

# last recorded rotation
last_rot=none
[ -f "$LAST_ROT_FILE" ] && last_rot=$(cat "$LAST_ROT_FILE")

echo Last rotation status: $last_rot

if [ -z "$1" ]; then
 
	case $last_rot in
	  none)
		  if [ $((RANDOM%2)) = 1 ]; then
		    ROT=right
		  else
		    ROT=normal
		  fi
		  ;;
	  right)
		  ROT=normal
		  ;;
	  normal)
		  ROT=right
		  ;;
	  left)
		  ROT=inverted
		  ;;
	  inverted)
		  ROT=left
		  ;;
	  *)
		  ROT=normal
		  ;;
	esac

else
  ROT=$1
fi

echo New rotation: $ROT

do_rotate $XDISPLAY $ROT

[ -f "$LAST_ROT_FILE" -o ! -e "$LAST_ROT_FILE" ] && (echo -n $ROT > "$LAST_ROT_FILE")

