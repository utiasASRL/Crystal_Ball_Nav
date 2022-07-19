
# Annotate real lidar point clouds and generate SOGMs

## Setup 

### Step 1: Docker Image

For convenience we provide a Dockerfile which builds a docker image able to run the code. To build this image simply run the following commands:

```
cd Docker/noetic_pytorch_image
./docker_build.sh
```

The image will be built following the provided Dockerfile. You might need to adapt this file depending on your system. In particular, you might need to change the version of CUDA and thus Pytorch depending on your GPU.

Note that the username inside the docker image is automatically copied from the one used to build the image, to avoid the permission conflicts happening when creating files as root inside a container.


### Step 2: Cpp wrappers 

Our code uses c++ wrappers, like the original KPConv repo. They are very easy to compile:

```
cd Scripts
./run_in_pytorch.sh -c "./compile_wrappers.sh"
```

## Data

### Preprocessed data for fast reproducable results

Download our UTIn3D Dataset [here](https://github.com/utiasASRL/UTIn3D) and our simulated data from our [old repository](https://github.com/utiasASRL/Deep-Collison-Checker).

You should have a Data folder looking like, with all zip file uncompressed:

```
    #   Data
    #   |---KPConv_data
    #   |---Simulation
    #   |---Simulation_v2
    #   |---UTIn3D_A
    #   |---UTIn3D_H
```

## Run the Annotation process

### Step by step

If you want to try the annotation process yourself, maybe modify some of the parameters, follow these steps:

1) Have a look at the dataset sessions defined in `SOGM-3D-2D-Net/MyhalCollision_sessions.py`.
2) Have a look at the file `SOGM-3D-2D-Net/annotate_MyhalCollision.py` where the annotation is started.
3) Start the python file:
   ```
   ./run_in_pytorch.sh -c "python3 annotate_MyhalCollision.py"
   ```
4) Because the data is already annotated, the script starts a visualization tool with the function `inspect_sogm_sessions`.
    - Enter the number of sessions you want to be able to visualize (too many makes it hard to click on the buttons).
    - Change session by clicking the radio buttons in the first window.
    - Navigate within the session with the slider in the second window.
5) Now if you are curious to see the annotation code working, delete (or move) the annotations:
    ```
    Data/UTIn3D_H/annotated_frames
    Data/UTIn3D_H/annotation
    Data/UTIn3D_H/collisions
    ```
6) Have a look at the functions:
    - *annotation_process* (`SOGM-3D-2D-Net/slam/PointMapSLAM.py` L1893) 
    - *collision_annotation* (`SOGM-3D-2D-Net/datasets/MyhalCollision.py` L2550) 

    and their parameters, that you can try to modify.
7) Run the code again:
   ```
   ./run_in_pytorch.sh -c "python3 annotate_MyhalCollision.py"
   ```
The annotation process takes quite some time. Annotated point clouds are saved in the folder `Data/UTIn3D_H/annotation`.

### Some details

The script `./run_in_pytorch.sh -c "XXXXXXXXX"` runs a command `XXXXXXXXX` from inside the `SOGM-3D-2D-Net` folder.

You can also add the argument -d to run the container in detach mode (very practical for annotation and training which are both very long).


## Going further: building a dev environment using Docker and VSCode

We provide a simple way to develop over our code using Docker and VSCode. First start a docker container specifically for development:

```
cd Scripts
./run_in_pytorch.sh -dv
```

Then then attach visual studio code to this container named `dev-SOGM`. For this you need to install the docker extension, then go to the list of docker containers running, right click on `dev-SOGM`, and `attach visual studio code`.

You can even do it over shh by forwarding the right port. Execute the following commands (On windows, it can be done using MobaXterm local terminal):

```
set DOCKER_HOST="tcp://localhost:23751"
ssh -i "path_to_your_ssh_key" -NL localhost:23751:/var/run/docker.sock  user@your_domain_or_ip
```

The list of docker running on your remote server should appear in the list of your local VSCode. You will need the extensions `Remote-SSH` and `Remote-Containers`.

