#!/bin/bash


# Import rosbags from orin
rsync -aPvh polus@cpr-tor59-xav02:/home/polus/0-VelodyneMapping/rosbags ../Data/Real/

source "/opt/ros/noetic/setup.bash"
python3 process_rosbags.py