#!/bin/bash

now=`date +%Y-%m-%d_%H-%M-%S`
NOHUP_FILE="$PWD/../SOGM-3D-2D-Net/results/exp_$now-log.txt"
PID_FILE="$PWD/../SOGM-3D-2D-Net/results/exp_$now-pid.txt"
nohup ./multiple_exp.sh > "$NOHUP_FILE" 2>&1 &
echo $! > "$PID_FILE"