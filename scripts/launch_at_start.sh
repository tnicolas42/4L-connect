#!/bin/zsh

# add this line to /etc/rc.local to auto start robot
#/bin/su -l tim -c ". ~/4L-connect/scripts/launch_at_start.sh"

if [[ -z "${LAUNCH_AT_START}" ]]; then
  LAUNCH_AT_START="1"  # set a default value if the env variable doesn't exist
else
  LAUNCH_AT_START="${LAUNCH_AT_START}"
fi
if [[ "${LAUNCH_AT_START}" == "0" ]]; then
	exit 0
fi

if [[ "${LAUNCH_AT_START}" == "1" ]]; then
	./run.sh
fi

exit 0
