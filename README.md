README.md WIP

Dockerfile for running minicom to administer console devices, such as Cisco switches in otherwise restrictive environments, such as immutable Linux distros or where only snap or flatpak type of packages are allowed. 

I have tried minicom as a snap package, but it does not seem to allow saving minicom profiles. Also, snapd is not available in all environments.

Pretty much all distros support Doccker so running this program as a Docker container should work in most if not all situations, I think.

However, this Dockerfile was just an attempt to see if I could get this built using an Alpine base image from an APKBUILD file. It was fairly trivial creating a Dockerfile which installed the existing Alpine package for minicom. However, the official package has an error in the APKBUILD that causes minicom to save configuration files in the etc root instead of in a dedicated minicom directory. So, this Dockerfile installs the necessary dependencies for building minicom and downloads the APKBUILD file, modifies the conf directory, builds, and installs minicom into the container environment.

It might just be better using a Debian or other base image instead of Alpine. I still have yet to evaluate which is the better route. 

Anyways, for running this:
build with: docker build -t minicom .

1st time run with: sudo docker run --device=/dev/ttyUSB0 -it --rm --name=minicom -v $PWD/config:/etc/minicom minicom -s
where: 
  device is the serial device attached to the console to administer
  $PWD/config is the local path to store minicom profiles

Modify the settings according to your application and save as a custom filename and exit.

Afterwards, simply run:
  sudo docker run --device=/dev/ttyUSB0 -it --rm --name=minicom -v $PWD/config:/etc/minicom minicom profilename
