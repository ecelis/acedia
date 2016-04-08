LexSys Deployment
=================


    git clone git@github.com:ecelis/acedia.git


Docker
------

### Build

`basename` identifica el ambiente base, por ejemplo Cliente A corre
RHEL 6 con Oracle y Cliente B corre CentOS 7 con PostgreSQL, podemos
construir imagenenes base `lexsys/cliente_a` y `lexsys/cliente_b`.

`build` identifica la fecha en que se hizo el build, puede servir como
referencia para release minor version. El formato es 2 dígitos del año,
2 dígitos del mes, 2 dígitos del día. Ej. 160321. Si es Necesario hacer
más de un buld por día, puede agregarse 2 dígitos de hora y 2 dígitos de
minutos. 160320945


    docker build -t lexsys/<basename>:<build> .


### Run


    docker run --name <ambiente_a> \
      -P -p 22 -p 80 -p 443 -p 3000 -p 3002 -p 3003 -p 3004 -p 3006
      -v $HOME:/home/lexusr



Instalador
----------

El instalador se crea con Makeself una herramienta auto-extraible para
sistemas Unix https://github.com/megastep/makeself

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
      $(pwd) /tmp/lexinstall_<DB>_<OS>.run "LexSys 2 <DB> <OS>"


Notas
-----

Nube docker `push` a $HOME/deployments un directorio con un
ambiente completo y configurado. Este directorio se monta como
volumen de un contenedor docker.

Previamente a iniciar el contenedor se crea en el host una base de
datos mongo para el editor y log del API. También se configura un host
virtual de nginx para los módulos del sistema.

