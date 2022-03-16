#!/bin/bash

#############
# Description
#############

# This script is called from the ros1-ros2 foxy docker and does the following:
#
# 1) Read parameters including start time, filter etc
# 2) Start the ros nodes that we want:
#       > Localization
#       > Move Base
#           - Local planner
#           - Global Planner
#       > Deep SOGM predict
#       > (pointfilter, others ...)


############
# Parameters
############

# # Initial sourcing
source "/opt/ros/noetic/setup.bash"
source "nav_noetic_ws/devel/setup.bash"

# Printing the command used to call this file
myInvocation="$(printf %q "$BASH_SOURCE")$((($#)) && printf ' %q' "$@")"

# Init
XTERM=false     # -x
SOGM=false      # -s
TEB=false       # -b
MAPPING=2       # -m (arg)

# Parse arguments
while getopts xsbm: option
do
case "${option}"
in
x) XTERM=true;;     # are we using TEB planner
s) SOGM=true;;     # are we using SOGMs
b) TEB=true;;               # are we using TEB planner
m) MAPPING=${OPTARG};;      # use gmapping, AMCL or PointSLAM? (respectively 0, 1, 2)
esac
done

# Wait for a message with the flow field (meaning the robot is loaded and everything is ready)
echo ""
echo "Waiting for Robot initialization ..."
until [[ -n "$puppet_state_msg" ]]
do 
    sleep 0.5
    puppet_state_msg=$(rostopic echo -n 1 /puppet_state | grep "running")
done 
echo "OK"

# Get parameters from ROS
echo " "
echo " "
echo -e "\033[1;4;34mReading parameters from ros\033[0m"

rosparam set using_teb $TEB
rosparam set loc_method $MAPPING

GTCLASS=$(rosparam get gt_class)
c_method=$(rosparam get class_method)
TOUR=$(rosparam get tour_name)
t=$(rosparam get start_time)
FILTER=$(rosparam get filter_status)

echo " "
echo "START TIME: $t"
echo "TOUR: $TOUR"
echo "MAPPING: $MAPPING"
echo "FILTER: $FILTER"
echo "GTCLASS: $GTCLASS"
echo "TEB: $TEB"


####################
# Start Localization
####################

echo " "
echo " "
echo -e "\033[1;4;34mStarting localization\033[0m"

# First get the chosen launch file
if [ "$MAPPING" = "0" ] ; then
    loc_launch="jackal_velodyne gmapping.launch"
elif [ "$MAPPING" = "1" ] ; then
    loc_launch="jackal_velodyne amcl.launch"
else
    loc_launch="point_slam simu_ptslam.launch filter:=$FILTER gt_classify:=$GTCLASS"
fi

if [ "$FILTER" = true ] ; then
    scan_topic="/filtered_points"
else
    scan_topic="/velodyne_points"
fi

# Add map path
loc_launch="$loc_launch scan_topic:=$scan_topic init_map_path:=$HOME/Deep-Collison-Checker/Data/Simulation_v2/slam_offline/2020-10-02-13-39-05/map_update_0001.ply"

# Start localization algo
if [ "$XTERM" = true ] ; then
    xterm -bg black -fg lightgray -xrm "xterm*allowTitleOps: false" -T "Localization" -n "Localization" -hold \
        -e roslaunch $loc_launch &
else
    NOHUP_LOC_FILE="$PWD/../Data/Simulation_v2/simulated_runs/$t/logs-$t/nohup_loc.txt"
    nohup roslaunch $loc_launch > "$NOHUP_LOC_FILE" 2>&1 &
fi

# Start point cloud filtering if necessary
if [ "$FILTER" = true ]; then
    if [ "$MAPPING" = "0" ] || [ "$MAPPING" = "1" ]; then
        NOHUP_FILTER_FILE="$PWD/../Data/Simulation_v2/simulated_runs/$t/logs-$t/nohup_filter.txt"
        nohup roslaunch jackal_velodyne pointcloud_filter2.launch gt_classify:=$GTCLASS > "$NOHUP_LOC_FILE" 2>&1 &
    fi
fi

echo "OK"

##################
# Start Navigation
##################

echo " "
echo " "
echo -e "\033[1;4;34mStarting navigation\033[0m"

# Chose parameters for global costmap
if [ "$MAPPING" = "0" ] ; then
    global_costmap_params="gmapping_costmap_params.yaml"
else
    if [ "$FILTER" = true ] ; then
        global_costmap_params="global_costmap_filtered_params.yaml"
    else
        global_costmap_params="global_costmap_params.yaml"
    fi
fi

# Chose parameters for local costmap
if [ "$FILTER" = true ] ; then
    local_costmap_params="local_costmap_filtered_params.yaml"
else
    local_costmap_params="local_costmap_params.yaml"
fi

# Chose parameters for local planner
if [ "$TEB" = true ] ; then
    if [ "$SOGM" = true ] ; then
        local_planner_params="teb_params_sogm.yaml"
    else
        local_planner_params="teb_params_normal.yaml"
    fi
else
    local_planner_params="base_local_planner_params.yaml"
fi

# Chose local planner algo
if [ "$TEB" = true ] ; then
    local_planner="teb_local_planner/TebLocalPlannerROS"
else
    local_planner="base_local_planner/TrajectoryPlannerROS"
fi

# Create launch command
nav_command="roslaunch jackal_velodyne navigation.launch"
nav_command="${nav_command} global_costmap_params:=$global_costmap_params"
nav_command="${nav_command} local_costmap_params:=$local_costmap_params"
nav_command="${nav_command} local_planner_params:=$local_planner_params"
nav_command="${nav_command} local_planner:=$local_planner"

file does not exist [/home/hth/Deep-Collison-Checker/Myhal_Simulator/nav_noetic_ws/src/jackal_velodyne/params/teb_normal_params.yaml]


# Start navigation algo
if [ "$XTERM" = true ] ; then
    xterm -bg black -fg lightgray -xrm "xterm*allowTitleOps: false" -T "Move base" -n "Move base" -hold \
        -e $nav_command &
else
    NOHUP_NAV_FILE="$PWD/../Data/Simulation_v2/simulated_runs/$t/logs-$t/nohup_nav.txt"
    nohup $nav_command > "$NOHUP_NAV_FILE" 2>&1 &
fi

echo "OK"


##################
# Run Deep Network
##################

echo " "
echo " "
echo -e "\033[1;4;34mStarting SOGM prediction\033[0m"

if [ "$SOGM" = true ] ; then
    cd onboard_deep_sogm/scripts
    ./collider.sh #TODO THIS IS THE FILE FOR THE ROBOT< SSO CREATE NEW ONE WITH THE RIGHT SOURCING FOR THE SIMU
fi
echo "OK"
echo " "
echo " "

# Wait for eveyrthing to end before killing the docker container
sleep 10
sleep 10
sleep 10
sleep 10
sleep 10
sleep 10
sleep 10
sleep 10
sleep 1000
sleep 1000
sleep 1000
sleep 1000
sleep 1000
sleep 1000
sleep 1000
sleep 1000



