# BRASH Tools
BRASH is a NASA-funded Phase II STTR focused on developing tools for integrating ROS2 with Flight Software (FSW) tools such as cFS and F'.

### Contact
Stephen Hart swhart@traclabs.com


# Installation notes for BRASH on Ubuntu 22.04 using ROS2 humble

### Install Ubuntu
1. Install Ubuntu 22.04 LTS
    * Use desktop install
    * Choose Minimal installation
    * Select Download updates while installing
    * Select Install 3rd party software
2. Once install is complete, update all packages
3. Install git and pip
    * `sudo apt install git python3-pip`

### Install ROS2 Humble
1. Update apt environment
    * `sudo apt install software-properties-common`
    * `sudo add-apt-repository universe`
    * `sudo apt update && sudo apt install curl -y`
2. Add ROS2 to apt
    * `sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg`
    * `echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null`
    * `sudo apt update && sudo apt upgrade`
3. Install ROS2
    * `sudo apt install ros-humble-desktop`
    * `sudo apt install ros-dev-tools`
4. Update environment for ROS2
    *  Add `. /opt/ros/humble/setup.bash` to your .bashrc file
5. Install other dependencies
    *  `sudo apt install python3-wstool python3-rosdep2`
    *  `rosdep update`
    *  `sudo apt install ros-dev-tools ros-humble-joint-state-publisher-gui`

### Install TRACLabs cFS
1. Install software
    * `cd ~/code`
    * `git clone git@github.com:traclabs/cFS.git TL_cFS`
    * `cd TL_cFS`
    * `git checkout submodule-cleanup`
    * `git submodule init`
    * `git submodule update`
    * `git checkout main`
    * `cp cfe/cmake/Makefile.sample Makefile`
    * `cp -r cfe/cmake/sample_defs sample_defs`
    * `make SIMULATION=native prep`
    * `make`
    * `make install`
    * `pip install pyzmq PyQt5`
2. Test the install
    * `cd build/exe/cpu1`
    * `./core-cpu1 2>&1 | tee out.txt`

### Install BRASH
1. Install software
    * `cd ~/code`
    * `mkdir humble_ws`
    * `cd humble_ws`
    * `git clone git@bitbucket.org:traclabs/brash.git`
    * `cd brash`
    * `git checkout vcstool`
    * `vcs import src < brash.repos`
2. Compile and test
    * `colcon build --symlink-install`
    * `./colcon_test.sh`

