# LexSys Deployment

This repository holds scripts to build and ship docker images for LexSys
deployment.

There are two images, one is the Base Image which holds everything
needed to run all LexSys modules.

The Main Image is built based of Base Image and it holds an actual
LexSys install ready to be deployed.


    git clone git@github.com:ecelis/acedia.git


## Docker

Docker requires Linux kernel 3.10 or later on a 64 bit system.


#### Install Docker in RHEL/CentOS


    sudo tee /etc/yum.repos.d/docker.repo <<-EOF
    [dockerrepo]
    name=Docker Repository
    baseurl=https://yum.dockerproject.org/repo/main/centos/7
    enabled=1
    gpgcheck=1
    gpgkey=https://yum.dockerproject.org/gpg
    EOF
    yum -y install docker-engine
    systemctl enable docker
    systemctl start docker


#### Install Docker in Debian 8 (Jessie)


    apt-get purge lxc-docker*
    apt-get purge docker.io*
    apt-get update
    apt-get install apt-transport-https ca-certificates
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
      --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > \
      /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-cache policy docker-engine
    sudo apt-get update
    sudo apt-get install docker-engine


### Build Base Image

`basename` tells the operating system and database.

`build` it tells the build date.


    docker build -t lexsys/<basename>:`date +%F-%H%M` .
