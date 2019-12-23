#!/bin/zsh

DIR="`git rev-parse --show-toplevel`"

SOURCE="source $DIR/scripts/4Lrc.sh"
if [[ "`cat ~/.zshrc | grep $SOURCE`" == "" ]]; then
	echo "$SOURCE" >> ~/.zshrc
fi
