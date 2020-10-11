export TMUX_SESSION=4L  # name of th tmux session
export LAUNCH_AT_START=1  # launch the server on startup (0 false, 1 true)
export IP_4L=192.168.0.1
export DIR4L="$HOME/4L-connect/"
alias python='LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libatomic.so.1.2.0 python'
source ~/4L-connect/scripts/arduino.sh
