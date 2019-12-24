#!/bin/zsh

DIR="`git rev-parse --show-toplevel`"

SOURCE="source $DIR/scripts/4Lrc.sh"
if [[ "`cat ~/.zshrc | grep $SOURCE`" == "" ]]; then
	echo "$SOURCE" >> ~/.zshrc
fi

DIR4L="export DIR4L=$DIR"
if [[ "`cat ~/.zshrc | grep $DIR4L`" == "" ]]; then
	echo "$DIR4L" >> ~/.zshrc
fi

pip3 install -r "$DIR/requirements.txt"

python3 $DIR/djangoWebsite/manage.py makemigrations
python3 $DIR/djangoWebsite/manage.py migrate
python3 $DIR/djangoWebsite/manage.py createsuperuser
