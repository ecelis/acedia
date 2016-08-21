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


### Run


    docker run --name <ambiente_a> \
      -P -p 22 -p 80 -p 443 -p 3000 -p 3002 -p 3003 -p 3004 -p 3006
      -v $HOME:/home/lexusr



## Instalador

El instalador se crea con Makeself una herramienta auto-extraible para
sistemas Unix https://github.com/megastep/makeself


    cd $TMPDIR
    git clone https://github.com/megastep/makeself



Se puede añadir el parametro `--setup deployment/build.sh` para que
descargue dependencias de python y nodejs después de descomprimir.


### Pasos para crear el instalador

1. Crea un directorio de trabajo BASE_DIR ej. `mkdir /tmp/release/0.2`
2. Ejecuta `src/build.sh`
3. Crea el archivo `RELEASE` de acuerdo a las instrucciones más
   adelante.


El achivo `RELEASE` contiene los commit de git que componen una versión liberada


    cd $BASE_DIR
    touch RELEASE
    cd EDITOR
    echo "$(git log -n 1 --pretty=oneline | cut -d' ' -f 1) \
      $(pwd | cut -d'/' -f7)" >> ../RELEASE
    cd envy
    echo "$(git log -n 1 --pretty=oneline | cut -d' ' -f 1) \
      $(pwd | cut -d'/' -f7)" >> ../RELEASE
    cd sloth
    echo "$(git log -n 1 --pretty=oneline | cut -d' ' -f 1) \
      $(pwd | cut -d'/' -f7)" >> ../RELEASE
    cd wpride
    echo "$(git log -n 1 --pretty=oneline | cut -d' ' -f 1) \
      $(pwd | cut -d'/' -f7)" >> ../RELEASE
    cd wrath
    echo "$(git log -n 1 --pretty=oneline | cut -d' ' -f 1) \
      $(pwd | cut -d'/' -f7)" >> ../RELEASE


    /vagrant/makeself/makeself.sh --base64 --notemp --current \
      $(pwd) /tmp/lexinstall-<DB>-<OS>.run "LexSys 2 <DB> <OS>"


### Notas


Nube docker `push` a $HOME/deployments un directorio con un
ambiente completo y configurado. Este directorio se monta como
volumen de un contenedor docker.

Previamente a iniciar el contenedor se crea en el host una base de
datos mongo para el editor y log del API. También se configura un host
virtual de nginx para los módulos del sistema.

## Referencias

* [Instalación Docker en RHEL](https://docs.docker.com/engine/installation/linux/rhel/)
