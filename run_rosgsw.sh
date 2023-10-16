#!/usr/bin/env bash
set -e

# This script runs the ROS GSW Applications and logs stdout+stderr to discrete log files
# It is primarily intended for usage within a Docker container

LOG_DIR="."

DO_ROS_SOURCE=0
DO_LOCAL_SOURCE=1
ROS_VERSION="galactic"

CFDP_DIR=cfdp/rosgsw
CFDP_EID=1

if [[ $DO_ROS_SOURCE -eq 1 ]]; then
    echo "source /opt/ros/${ROS_VERSION}/setup.bash"
fi


if [[ $DO_LOCAL_SOURCE -eq 1 ]]; then
    source install/local_setup.sh
fi

# Start ROS GSW Interface
#PARAMS="-p \"plugin_params.commandHost=fsw\""
#export FSW_CMD_HOST=fsw
echo "Starting cfe_bridge"
ros2 launch cfe_plugin cfe_bridge.launch.py &> ${LOG_DIR}/rosgsw_cfebridge.log &

# Start ROS GSW CFDP Instance
echo "Starting ROSGSW CFDP"
mkdir -p ${CFDP_DIR}
ros2 run cfdp_wrapper cfdp_wrapper.py --ros-args -r __node:=cfdpgsw -p entityID:=${CFDP_EID} -p "filestore:=${CFDP_DIR}" &> ${LOG_DIR}/rosgsw_cfdp.log &
              
# Wait for any process to exit
echo "Waiting for tasks to exit"
wait -n

# Exit with status of process that exited first
exit $?
