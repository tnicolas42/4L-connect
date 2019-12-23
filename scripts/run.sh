#!/bin/zsh

# create the tmux session
tmux new-session -s $TMUX_SESSION -d

# split the terminal in 2 part
# *---*---*
# | 0 | 1 |
# *---*---*
tmux split-window -t $TMUX_SESSION:0.0 -h

# start the 4L
# *-------------------*--------------------*
# |                   |                    |
# |                   |                    |
# | django-server     | free               |
# |                   |                    |
# |                   |                    |
# *-------------------*--------------------*

# run django server
tmux send-keys -t $TMUX_SESSION:0.0 'while [ 1 ]; do source ~/.zshrc ; cd $DIR4L/djangoWebsite ; python3 manage.py runserver ; if [ "`echo $?`" == "0" ]; then break ; fi ; sleep 1 ; done' C-m

echo "access with: tmux a -t $TMUX_SESSION"
echo "stop with: ./kill.sh"

exit 0