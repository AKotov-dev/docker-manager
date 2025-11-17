# DockerManager
The GUI is designed to manage Docker images and containers. It allows you to monitor the status of certain objects in real time and perform entry-level operations on them (right-click menu). It can also be useful as a monitor of Docker objects activity during deployment and configuration.
+ Getting/Downloading images from Docker storage
+ Launching/Stopping images and containers with and without additional commands
+ Launching images and containers + logging into BASH (editing containers)
+ Getting information about the version of containers
+ Deleting images and containers
+ Backup and Restore docker images
+ Creating an image from a container
+ Creating an image via Dockerfile
+ Import the contents from a tarball to create a filesystem image
+ Export a container’s filesystem as a tar archive
+ Renaming images and containers
+ Login/Logout, Push the image to DockerHub  
  
Don't forget to include the active user in the `docker` group: `usermod -aG docker $LOGNAME && reboot`
  
**Working directory:** ~/DockeManager  
**Dependencies:** docker, sakura, polkit, systemd, (docker.io for Ubuntu)  
  
![](https://github.com/AKotov-dev/docker-manager/blob/main/ScreenShot.png)
