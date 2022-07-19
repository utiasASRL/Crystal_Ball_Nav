
# Evaluate/Visualize the network results

## Setup 

### Step 1: Docker Image

To run the simualtion you need multiple environments. For convenience we provide Dockerfiles which builds docker images able to run the code. To build these images, simply run the following commands:

```
cd Docker/noetic_pytorch_image
./docker_build.sh

cd ../foxy_sogm_image
./docker_build.sh

cd ../melodic_simu_image
./docker_build.sh
```

The images will be built following the provided Dockerfiles. You might need to adapt these files depending on your system. In particular, you might need to change the version of CUDA and thus Pytorch depending on your GPU.

Note that the username inside the docker image is automatically copied from the one used to build the image, to avoid the permission conflicts happening when creating files as root inside a container.


### Step 2: Compilation

Our code uses c++ wrappers, like the original KPConv repo. They are very easy to compile:

```
cd Scripts
./run_in_pytorch.sh -c "./compile_wrappers.sh"
```

Many things have to be compiled for the code to work. We provide a compiling script to make it easy:

```
cd Scripts
./build_all.sh
```

## Run the Simulation


### Simulation with basic navigation

In a first console start the simulation with:

```
./run_in_melodic.sh -c "./simu_master.sh -vr -t 2022-A -p Flow2_params"
```

In a second console start the robot navigation with:

```
./run_in_foxy.sh -c "./nav_master.sh -b -m 2"
```

### Simulation with SOGM predictions

In a first console start the simulation with:

```
./run_in_melodic.sh -c "./simu_master.sh -fgvr -t 2022-A -p Flow2_params"
```

In a second console start the robot navigation with:

```
./run_in_foxy.sh -c "./nav_master.sh -bs -m 2"
```

### More details

The simulation script `./simu_master.sh` runs in the melodic container. It takes the following parameters:

* `-p \[arg\]`: Specify the parameter files we are we using, located in: `SIMUPATH/params`.
* `-t \[arg\]`: Specify the tour (list of goals), located in: `SIMUPATH/tours`.
* `-l \[arg\]`: Specify a prexisting world to load. Leave untouched to generate a new one.
* `-v`: Option to use a Gazebo GUI visualization.
* `-r`: Option to use a RVIZ visualization.
* `-f`: Option to start a pointcloud filtering node.
* `-g`: Option to provide simulation groundtruth labels
* `-x`: Option to use xterm windows (otherwise node are started in nohup mode)

N.B. `SIMUPATH/` = `Myhal_Simulator/simu_melodic_ws/src/myhal_simulator/`

The navigation script `./nav_master.sh` runs in the foxy container. It takes the following parameters:

* `-m \[arg\]`: Specify the mapping algorithm used. Always use `-m 2` for PointMap.
* `-b`: Option to use TEB planner. Default is the ROS base planner (DWA).
* `-s`: Option to start SOGM predictions and use them in navigation.
* `-g`: Option to use preloaded actor trajectories for groundtruth GtSOGM (only work when a prexisting world is loaded in the simulation script).
* `-l`: Option to use preloaded actor trajectories for linear extrapolation LinSOGM (only work when a prexisting world is loaded in the simulation script).
* `-i`: Option to ignore dynamic obstacle instead of using SOGMs
* `-x`: Option to use xterm windows (otherwise node are started in nohup mode)

N.B. `-b -m 2` should always remain. `-i`, `-l`, `-g`, and `-s` ar incompatible, choose only one.



### Other example: Run a simulation with a preexisting world.

Run a first simulation with the previous commands. Wait until the end. A dated folder `YYYY-MM-DD_HH-MM-SS` is created in `Data/Simulation_v2/simulated_runs` to save your simulation world and data.

Now run the following commands in two different consoles:

```
./run_in_melodic.sh -c "./simu_master.sh -rfg -t 2022-A -p Flow2_params -l 2022-05-18-22-22-02"
```
```
./run_in_foxy.sh -c "./nav_master.sh -bg -m 2"
```

You should see perfect SOGM in RVIZ.