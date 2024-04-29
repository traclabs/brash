#!/usr/bin/env bash
set -e

# This script runs the ROS FSW Applications and logs stdout+stderr to discrete log files
# It is primarily intended for usage within a Docker container

LOG_DIR="."

DO_ROS_SOURCE=0
DO_LOCAL_SOURCE=1
ROS_VERSION="galactic"

CFDP_DIR=cfdp/rosfsw
CFDP_EID=2

if [[ $DO_ROS_SOURCE -eq 1 ]]; then
    echo "source /opt/ros/${ROS_VERSION}/setup.bash"
fi


if [[ $DO_LOCAL_SOURCE -eq 1 ]]; then
    source install/local_setup.sh
fi

# Start ROS FSW Interface
echo "Starting cfe_sbn_bridge"
ros2 launch cfe_sbn_plugin cfe_sbn_bridge.launch.py cfe_sbn_config:='cfe_sbn_config_multihost.yaml' &> ${LOG_DIR}/rosfsw_sbn.log &

# Start ROS FSW CFDP Instance
echo "Starting ROSGSW CFDP"
mkdir -p ${CFDP_DIR}
ros2 launch cfdp_wrapper cfdp_wrapper.launch.py namespace:="/flightsystem" entityID:=${CFDP_EID} filestore:=${CFDP_DIR} &> ${LOG_DIR}/rosfsw_cfdp.log &


# Wait for any process to exit
echo "Waiting for tasks to exit"
wait -n

# Exit with status of process that exited first
exit $?
