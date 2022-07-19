
# Train our network on annotated data

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
./run_in_pytorch.sh.sh -c "./compile_wrappers.sh"
```

## Data

### Preprocessed data for fast reproducable results

Download our UTIn3D Dataset [here](https://github.com/utiasASRL/UTIn3D) and our simulated data from our [old repository](https://github.com/utiasASRL/Deep-Collison-Checker).

You should have a Data folder looking like, with all zip file uncompressed:

```
    #   Data
    #   |---KPConv_data
    #   |---Simulation
    #   |---UTIn3D_A
    #   |---UTIn3D_H
```

## Run the training

### Step by step

If you want to try the annotation process yourself, maybe modify some of the parameters, follow these steps:

1) Have a look at the training script `SOGM-3D-2D-Net/train_MultiCollision.py`
2) You can change network and training parameters in the *MultiCollisionConfig* class
3) At L520, you can change the data that is used for training. By default the network uses UTIn3D_A + UTIn3D_H + Simulation
4) At L123, you can change the proportion of simulated data used by the network (last value in the list).
5) Start the training:
   ```
   ./run_in_pytorch.sh -c "python3 train_MultiCollision.py"
   ```
   Or with -d for detached mode:
   ```
   ./run_in_pytorch.sh -d -c "python3 train_MultiCollision.py"
   ```
6) Network model and results are saved in a dated folder `SOGM-3D-2D-Net/results/Log_YYYY-MM-DD_HH-MM-SS`

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

