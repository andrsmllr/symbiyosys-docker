# symbiyosys-docker
A dockerfile to create a docker image for the SymbiYosys open source formal verification toolkit.  
Dockerfile for image [andrsmllr/symbiyosys on dockerhub](https://cloud.docker.com/repository/docker/andrsmllr/symbiyosys).  

## Usage:

./run_exec.sh [options]  
Will run the docker container like an executable, similar to invoking sby when SymbiYosys is installed on your system.  
The current working director will be added to the container by default.  
If files from other paths than the working directory are needed, you have to add these paths using the -v (--volume) option of docker.  

./run.sh  
Will run the docker container in interactive mode within the current directory.  
Inside the container SymbiYosys can be invoked with the sby command.  
The source code / binaries of the backend tools are stored under /usr/src.  
