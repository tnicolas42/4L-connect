#!/bin/zsh

if [[ -z "${TMUX_SESSION}" ]]; then
  TMUX_SESSION="4L"  # set a default value if the env variable doesn't exist
else
  TMUX_SESSION="${TMUX_SESSION}"
fi

tmux kill-session -t $TMUX_SESSION
