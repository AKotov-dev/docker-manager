# DockerManager
The GUI is designed to manage Docker images and containers. It allows you to monitor the status of certain objects in real time and perform entry-level operations on them (right-click menu). It can also be useful as a monitor of Docker objects activity during deployment and configuration. Despite DockerManager's modest capabilities, it is quite suitable for home use.
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
  
Starting with v2.0, multiple selections in lists are supported when deleting/stopping images/containers. To select multiple list entries, press and hold `Ctrl` while choosing an action from the pop-up menu. This enables the "Pause lists..." mode (see window title), which allows you to select records in static mode. Additionally, you can use the `Esc` button to interrupt frozen Dodnload/Upload processes when working with DockerHub.
  
Don't forget to include the active user in the `docker` group: `usermod -aG docker $LOGNAME && reboot`
  
**Working directory:** ~/DockerManager  
**Dependencies:** gtk2, docker, sakura, polkit, systemd, procps (libgtk2.0-0, docker.io for Ubuntu)  
  
![](https://github.com/AKotov-dev/docker-manager/blob/main/ScreenShot.png)
