#!/bin/bash
# https://github.com/SignalFlagZ/OpenCV-4-build-script-on-Raspbian-Stretch

user=`whoami`
echo 'Your Name :' ${user}

opencvbranch='4.0.1'

echo -e '\n----------'
echo 'Update repository'
sudo apt update
sudo apt -y upgrade

echo -e '\n----------'
echo 'Update libraries'
sudo apt-get install -y build-essential cmake unzip pkg-config
sudo apt-get install -y libjpeg-dev libpng-dev libtiff-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y libxvidcore-dev libx264-dev
sudo apt-get install -y libgtk-3-dev
sudo apt-get install -y libcanberra-gtk*
sudo apt-get install -y libatlas-base-dev gfortran

echo -e '\n----------'
echo 'Get OpenCV from git.'
cd ~/Downloads/
git clone --depth 1 --branch ${opencvbranch} https://github.com/opencv/opencv.git
git clone --depth 1 --branch ${opencvbranch} https://github.com/opencv/opencv_contrib.git

echo -e '\n----------'
echo 'Install virtualenv.'
sudo pip install virtualenv virtualenvwrapper
sudo pip3 install virtualenv virtualenvwrapper

echo -e '\n----------'
echo 'Modify profile.'
sed -i.bak -e "/# virtualenv and virtualenvwrapper/d" ~/.profile
sed -i -e "$ a # virtualenv and virtualenvwrapper" ~/.profile
sed -i -e "/export WORKON_HOME=\$HOME\/.virtualenvs/d" ~/.profile
sed -i -e "$ a export WORKON_HOME=\$HOME\/.virtualenvs" ~/.profile
sed -i -e "/export VIRTUALENVWRAPPER_PYTHON=\/usr\/bin\/python3/d" ~/.profile
sed -i -e "$ a export VIRTUALENVWRAPPER_PYTHON=\/usr\/bin\/python3" ~/.profile
sed -i -e "/source \/usr\/local\/bin\/virtualenvwrapper.sh/d" ~/.profile
sed -i -e "$ a source \/usr\/local\/bin\/virtualenvwrapper.sh" ~/.profile

echo -e '\n----------'
echo 'Make virtualenv.'
source ~/.profile
mkvirtualenv cv -p python3
workon cv

echo -e '\n----------'
echo 'Install numpy.'
pip install numpy

echo -e '\n----------'
echo 'Prepare to build OpenCV.'
cd ~/Downloads/opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=~/Downloads/opencv_contrib/modules \
-D ENABLE_NEON=ON \
-D ENABLE_VFPV3=ON \
-D BUILD_TESTS=OFF \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D BUILD_EXAMPLES=OFF ..

echo -e '\n----------'
echo 'Change swap file size.'
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo sed -i.bak 's/^#\?\(CONF_SWAPSIZE=\).*/\12048/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

echo -e '\n----------'
echo "Build OpenCV. It takes about 3 hours on RPi3B."
make -j4

echo -e '\n----------'
echo 'Install OpenCV.'
sudo make install
sudo ldconfig

echo -e '\n----------'
echo 'Change swap file size.'
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo sed -i 's/^#\?\(CONF_SWAPSIZE=\).*/\1100/' /etc/dphys-swapfile
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

echo -e '\n----------'
echo 'Make link.'
cd ~/.virtualenvs/cv/lib/python3.5/site-packages/
ln -s /usr/local/lib/python3.5/site-packages/cv2/python-3.5/cv2.cpython-35m-arm-linux-gnueabihf.so cv2.so
cd ~

echo -e '\n----------'
echo 'Completed.'
