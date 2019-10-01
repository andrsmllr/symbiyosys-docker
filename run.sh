#!/bin/bash
# Run docker container interactively.
docker run --rm -ti -v $(pwd):$(pwd) -u $(id -u) --workdir=$(pwd) andrsmllr/symbiyosys
