#!/bin/sh

# $ ARDUINO_BASE_HARD_CONNECTION=1.5 arduino_setup_port
# SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0010", ATTRS{devpath}=="1.5", SYMLINK+="arduinobase"

# this function setup the hard connection for new arduino
# you need to unplug and plug arduino to do this setup

# >>> arduino_setup BASE
# ttyACM0
# export ARDUINO_BASE_HARD_CONNECTION=1.2
function arduino_setup() {
	summary=""
	for arg in $@; do
		echo "${BOLD}${arg}${EOC}"
		echo "unplug your ${arg} arduino (press enter to continue)"
		read
		ls /dev > /tmp/before_arduino
		echo "plug your ${arg} arduino (press enter to continue)"
		read
		ls /dev > /tmp/after_arduino
		name="`diff /tmp/before_arduino /tmp/after_arduino | grep "tty" | cut -d' ' -f 2`" | head -1
		name="ttyACM0"
		usb_port="`udevadm info --name=/dev/${name} --attribute-walk | grep "ATTRS{devpath}" | sed "2, 100 d" | cut -d'"' -f 2`"
		if [[ "${usb_port}" == "" ]]; then
			echo "${RED}${BOLD}cannot get ${arg} arduino port${EOC}"
		else
			name_var="ARDUINO_${arg}_HARD_CONNECTION"
			echo "export $name_var=${usb_port}"
			summary="${summary}\nexport $name_var=${usb_port}"
			export $name_var=${usb_port}
			arduino_get ${arg}
		fi
		echo ""
	done
	echo "all environnement variables created:$summary"
}

# this function create the rules to setup link like /dev/arduinobase
# this function need the variables ARDUINO_<NAME>_HARD_CONNECTION (use arduino_setup to create these variables)

# >>> arduino_setup_port
# setup /dev/arduinobase
# setup /dev/arduinomodule
function arduino_setup_port() {
	sudo sh -c "echo -n '' > /etc/udev/rules.d/99-usb-serial.rules"
	name=BASE
	name_hard="ARDUINO_${name}_HARD_CONNECTION"
	hard_connection="`printenv ${name_hard}`"
	echo "-> ${name_hard}: ${hard_connection}"
#	if [ "${hard_connection}" == "" ]; then
#		echo "cannot find hard connection"
#		return
#	fi
	name_lower="`echo ${name} | tr '[:upper:]' '[:lower:]'`"
	echo "setup /dev/arduino${name_lower}"
	sudo sh -c "echo \"SUBSYSTEM==\\\"tty\\\", ATTRS{idVendor}==\\\"2341\\\", ATTRS{idProduct}==\\\"0010\\\", ATTRS{devpath}==\\\"${hard_connection}\\\", SYMLINK+=\\\"arduino${name_lower}\\\"\" >> /etc/udev/rules.d/99-usb-serial.rules"
	sudo udevadm control --reload-rules
	sudo udevadm trigger
}

# this function print the port of one arduino

# >>> get_arduino BASE
# ttyACM0
function arduino_get() {
	if [ "$1" == "" ]; then
		echo "usage: get_arduino <name1>, [name2, ...]\n\tname example: BASE"
	else
		for arg in $@; do
			name_hard="ARDUINO_${arg}_HARD_CONNECTION"
			name_port="ARDUINO_${arg}_PORT"
			hard_connection="`printenv ${name_hard}`"
			if [ "$hard_connection" == "" ]; then
				echo "${RED}${BOLD}[x] ${name_hard} is not defined -> try arduino_setup ${arg}${EOC}"
			else
				ok=false
				for arduino in $( ls /dev | grep "tty" ); do
					usb_port="`udevadm info --name=/dev/$arduino --attribute-walk | grep "ATTRS{devpath}" | sed "2, 100 d" | cut -d'"' -f 2`"
					if [ "${usb_port}" == "$hard_connection" ]; then
						name="`udevadm info --name=/dev/$arduino --attribute-walk | grep 'KERNEL==' | cut -d'"' -f 2`"
						export $name_port=$name
						echo "$name"
						ok=true
						break
					fi
				done
				if [ $ok == false ]; then
					echo "${RED}${BOLD}[x] unable to connect to ${arg} on ${hard_connection}: try to reconnect the arduino${EOC}"
				fi
			fi
		done
	fi
}
