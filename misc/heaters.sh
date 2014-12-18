#!/bin/bash

# heater.sh - Wrapper for heating control system via GPIO
# Copyleft 2014 - Nicolas AGIUS <nicolas.agius@lps-it.fr>

###########################################################################
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
###########################################################################

# The 4-orders pilot wire on electrical heaters works like that :
# 
#  - No connection : Full power
#  - Standard 230 V AC : Economic mode
#  - 230 V AC positive alternance : Off mode
#  - 230 V AC negative alternance : Anti-frost mode

# This script use Raspberry Pi's GPIO output to swith relays sending 230V to the pilot wire.
# Anti-frost is not implemented as is require one more relay. Only 2 are currently used.
# TODO: Add Raspberri Pi wiring schematics

# Select which GPIO port to use
GPIO_ECO=23
GPIO_OFF=24

# Internal variables
GPIO_PATH="/sys/class/gpio"
FILE_ECO="$GPIO_PATH/gpio$GPIO_ECO/value"
FILE_OFF="$GPIO_PATH/gpio$GPIO_OFF/value"

function exit_with_error
{
	echo "Syntax: $0 on|off|eco|status" >&2
	exit 3
}

function enable_gpio_port
{
	# Configure GPIO port as output
	if [ ! -e $GPIO_PATH/gpio$1/value ]; then
		echo $1 >$GPIO_PATH/export
		echo "out" > $GPIO_PATH/gpio$1/direction
	fi
}


# Check parameters
[ $# -ne 1 ] && exit_with_error

# Configure GPIO
enable_gpio_port $GPIO_ECO
enable_gpio_port $GPIO_OFF


case "$1" in
	on)
		echo 0 >$FILE_OFF
		echo 0 >$FILE_ECO
		;;
	eco)
		echo 0 >$FILE_OFF
		echo 1 >$FILE_ECO
		;;
	off)
		echo 0 >$FILE_ECO
		echo 1 >$FILE_OFF
		;;
	status)
		ECO=$(cat $FILE_ECO)
		OFF=$(cat $FILE_OFF)

		if [ "$ECO" -eq 0 -a "$OFF" -eq 0 ]; then
			echo "Full power mode."
		elif [ "$ECO" -eq 1 -a "$OFF" -eq 0 ]; then
			echo "Economic mode."
		elif [ "$ECO" -eq 0 -a "$OFF" -eq 1 ]; then
			echo "Off mode."
		else
			echo "ERROR: unpredictable mode."
		fi
		
		;;
	*)
		exit_with_error
		;;
esac

# vim: ts=4:sw=4:ai:noet