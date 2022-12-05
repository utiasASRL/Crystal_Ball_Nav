#!/bin/bash

username=$USER
userid=$UID

echo $username
echo $userid

echo ""
echo "Building image simple image for annotation"
echo ""

docker image build --build-arg username0=$username \
--build-arg userid0=$userid \
--shm-size=64g -t \
annot_$username .