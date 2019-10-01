#!/bin/bash
# Run docker container like an executable, i.e. './run_exec.sh foo.sby'
docker run --rm -v $(pwd):$(pwd) -u $(id -u) --workdir=$(pwd) --entrypoint=/usr/local/bin/sby andrsmllr/symbiyosys $@
