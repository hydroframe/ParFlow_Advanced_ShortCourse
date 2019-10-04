# ParFlow Advanced ShortCourse
*October 2019, University of Arizona*

*Instructors: Laura Condon (UA), Nick Engdahl (WSU), Reed Maxwell (CSM)

## Contents
This repo contains all of the exercises and slides for the short course. Materials for the introductory course are available [Here](https://github.com/hydroframe/ParFlow_Short_Course).

1. Slides: All of slides presented in the course
2. Solids_Domains: Exercises for creating and testing your own solid file domain_input
3. Solver-Scaling: Exercises for testing different solver configurations and scaling.  
4. Topographic_Processing: Exercises for processing topography and testing different overland flow boundary conditions.
5. CLM: Exercises experimenting with clm variables using single column exercises.
6. Additional_Materials: Additional reference slides mentioned in class.


## Instructions for ParFlow-Docker
Step by step instructions are written below. For more details refer to [the parflow github site](https://github.com/parflow/docker) and the [Docker Hub](https://hub.docker.com/r/parflow/parflow)

### Instructions for ParFlow-Docker on Mac
1. [Install Docker](docker.com)
2. Pull the docker image
```
docker pull parflow/parflow:latest
```
3. Create a directory to keep your ParFlow docker in. This should be a permanent location that you can add to your path. In this directory make a file called *parflow.sh* and add the following lines exactly as written here:
```
#!/bin/bash
docker run --rm -v $(pwd):/data parflow/parflow $*
```
4.  Change the  permissions of the file you just made to make it executable
```
    chmod     770 parflow.sh
```
5.  Add the location of your parflow.sh file to your PATH. Open your bash profile (e.g. `vi ~/.bash_profile`)  and add the following line (with the path to your parflow.sh file inserted) to your bash_profile
```
PATH=“/PathToparflow.sh/:${PATH}”
```
5. Source your bash_profile file
```
source ~/.bash_profile
```
6. Now you can run tcl scripts by doing the following (Note that you need to be in the same directory as your tcl script when you do the parflow.sh call).
```
parflow.sh default_single.tcl 1 1 1
```


### Instructions for ParFlow-Docker on PC
1. [Install Docker](docker.com)
2. Pull the docker image
```
docker pull parflow/parflow:latest
```
3. Create a directory to keep your ParFlow docker in. This should be a permanent location that you can add to your path. In this directory make a file called *parflow.bat* and add the following lines exactly as written here:
```
@echo off
docker run --rm -v %cd%:/data parflow/parflow %1 %2 %3 %4 %5 %6 %7 %8 %9
```
4.  Change the  permissions of the file you just made to make it executable
```
    chmod     770 parflow.sh
```
5.  Add the location of your parflow.sh file to your PATH. Open your bash profile (e.g. `vi ~/.bash_profile`)  and add the following line (with the path to your parflow.sh file inserted) to your bash_profile
```
PATH=“/PathToparflow.sh/:${PATH}”
```
5. Source your bash_profile file
```
source ~/.bash_profile
```
6. Now you can run tcl scripts by doing the following (Note that you need to be in the same directory as your tcl script when you do the parflow.sh call).
```
parflow.bat default_single.tcl 1 1 1
