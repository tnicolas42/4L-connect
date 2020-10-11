#!/bin/zsh

if [[ -z "${TMUX_SESSION}" ]]; then
  TMUX_SESSION="4L"  # set a default value if the env variable doesn't exist
else
  TMUX_SESSION="${TMUX_SESSION}"
fi

# create the tmux session
tmux new-session -s $TMUX_SESSION -d "zsh"

# split the terminal in 2 part
# *---*---*
# | 0 | 1 |
# *---*---*
#tmux split-window -t $TMUX_SESSION:0.0 -h

# start the 4L
# *-------------------*--------------------*
# |                   |                    |
# |                   |                    |
# | django-server     | free               |
# |                   |                    |
# |                   |                    |
# *-------------------*--------------------*

# run django server
#tmux send-keys -t $TMUX_SESSION:0.0 'while [ 1 ]; do source ~/.zshrc ; cd $DIR4L/djangoWebsite ; source ~/.profile ; workon cv ; python3 manage.py runserver ; if [ "`echo $?`" == "0" ]; then break ; fi ; sleep 1 ; done' C-m
tmux send-keys -t $TMUX_SESSION:0.0 'while [ 1 ]; do source ~/.zshrc ; cd $DIR4L/djangoWebsite ; source ~/4L-connect/venv/bin/activate ; python3 manage.py runserver --insecure $IP_4L:8000 ; if [ "`echo $?`" == "0" ]; then break ; fi ; sleep 1 ; done' C-m

echo "access with: tmux a -t $TMUX_SESSION"
echo "stop with: ./kill.sh"
