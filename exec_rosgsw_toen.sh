#!/usr/bin/env bash
set -e

DO_ROS_SOURCE=1
DO_LOCAL_SOURCE=1
ROS_VERSION="galactic"

ROSGSW_IP=${ROSGSW_IP:-"127.0.0.1"}

if [[ $DO_ROS_SOURCE -eq 1 ]]; then
    source /opt/ros/${ROS_VERSION}/setup.bash
fi


if [[ $DO_LOCAL_SOURCE -eq 1 ]]; then
    source install/local_setup.sh
fi

# TODO: Make dest_ip a parameter or ENV var
ros2 topic pub --once /groundsystem/to_lab_enable_output_cmd cfe_msgs/msg/TOLABEnableOutputCmdt "{\"payload\":{\"dest_ip\":\"${ROSGSW_IP}\"}}"
