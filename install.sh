#!/bin/sh

# https://www.pyimagesearch.com/2015/10/26/how-to-install-opencv-3-on-raspbian-jessie/

sudo apt-get update -y
sudo apt-get upgrade -y
sudo rpi-update
# reboot ?

# install depencies
sudo apt-get install build-essential git cmake pkg-config -y
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev -y
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev -y
sudo apt-get install libxvidcore-dev libx264-dev -y
sudo apt-get install libgtk2.0-dev -y
sudo apt-get install libatlas-base-dev gfortran -y
sudo apt-get install python2.7-dev python3-dev -y

# get opencv source code
cd ~
wget -O opencv.zip https://github.com/Itseez/opencv/archive/3.0.0.zip
unzip opencv.zip
wget -O opencv_contrib.zip https://github.com/Itseez/opencv_contrib/archive/3.0.0.zip
unzip opencv_contrib.zip

# setup python
sudo pip3 install virtualenv virtualenvwrapper
sudo rm -rf ~/.cache/pip
echo "export WORKON_HOME=$HOME/.virtualenvs\nsource /usr/local/bin/virtualenvwrapper.shv" > ~/.profile

source ~/.profile

cd ~
virtualenv cv -p python3.7
source ~/cv/bin/activate
pip install numpy

# install & compile opencv
source ~/cv/bin/activate
cd ~/opencv-3.0.0/
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
	-D CMAKE_INSTALL_PREFIX=/usr/local \
	-D INSTALL_C_EXAMPLES=ON \
	-D INSTALL_PYTHON_EXAMPLES=ON \
	-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.0.0/modules \
	-D BUILD_EXAMPLES=ON ..
