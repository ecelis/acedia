#!/bin/bash
##
## Los valores de las variables pueden cambiarse al momento de ejecución
## por ejemplo:
##
## LEXUSR=someuser LEXHOME=/opt/somedir lexinstall.sh
##
## Get Operating System version
OS_VERSION=$(cat /etc/redhat-release)
## Elegir base de datos oracle | postgresql | sqlite
LEXDB=${LEXDB:-oracle}
## Usuario
LEXUSR=${LEXUSR:-lexusr}
## Se declara la ruta base de la instalación
LEXHOME=${LEXHOME:-/home}/${LEXUSR}
## Directorio de logs
LOGDIR=${LOGDIR:-/var/log/lexsys}
## Directorio temporal donde se encuentran paquetes binarios requeridos
TMPDIR=${TMPDIR:-/tmp}
## Python Setuptools
PYSETUP=${PYSETUP:-19.6.2}
## virtualenv
PYVENV=${PYVENV:-14.0.5}
## PYPI
PYPI=${PYPI:-8.0.2}
## uWSGI
UWSGI=${UWSGI:-2.0.12}
## NodeJS
NODE=${NODE:-v4.2.6}

#### NO CAMBIE NADA A PARTIR DE ESTA LINEA SIN SABER EXACTAMENTE LO QUE HACE
## LexSys Modules
LEXAPI=${LEXHOME}/wrath
LEXEDITOR=${LEXHOME}/EDITOR
LEXDESK=${LEXHOME}/wpride
LEXPORTAL=${LEXHOME}/sloth
##
echo -e "Iniciando instalación LexSys\n"
echo -e "Sistema Operativo: ${OS_VERSION}\nBase de Datos: ${LEXDB}"
echo -e "Usuario: ${LEXUSR}\nDirectorio: ${LEXHOME}"
echo -e "Logs: ${LOGDIR}\nuWSGI: ${UWSGI}\nNodeJS: ${NODE}\n"
sleep 5
## Crear usuario dueño
useradd -m -d ${LEXHOME} -G wheel ${LEXUSR}
## Crear Directorios
mkdir -p ${LOGDIR}
chown -R ${LEXUSR}:${LEXUSR} ${LOGDIR}
## Actualizacion del SO e instalación de repositorios de YUM extra
yum update -y
yum install epel-release -y
# LexSys dependencias
yum -y install tar gzip make gcc gcc-c++ git \
  openssl-devel pcre-devel zlib-devel \
  python-devel python-pip \
  mongodb mongodb-server mongodb-devel
cd ${TMPDIR}
# wkhtmltox
#if [[ $OS_VERSION == *" 6."* ]]; then
#yum -y install \
#  http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos6-amd64.rpm
#elif [[ $OS_VERSION == *" 7."* ]]; then
#yum -y install \
#  http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm
#fi
## Dependencias según motor de base de datos
case ${LEXDB} in
"postgresql")
  if [[ $OS_VERSION == *" 7."* ]]; then
    # CentOS 7 yum install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm -y
    yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm
    # Add psql binaries to lexusr PATH
    echo 'export PATH=/usr/pgsql-9.4/bin:$PATH' >> ${LEXHOME}/.bashrc
  elif [[ $OS_VERSION == *" 6."* ]]; then
    # CentOS 6 http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-2.noarch.rpm
    yum install http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm -y
  fi
  yum -y install libpqxx libpqxx-devel \
    postgresql94 postgresql94-contrib postgresql94-devel
  # Add psql binaries to lexusr PATH
  echo 'export PATH=/usr/pgsql-9.4/bin:$PATH' >> ${LEXHOME}/.bashrc
  ;;
"oracle")
  yum -y install libaio
  rpm -Uvh /oracle-instantclient*.rpm
  #rpm -Uvh ${TMPDIR}/oracle-instantclient*.rpm
  if [[ -d /usr/lib/oracle/11.2/client64 ]]; then
    ORACLE_HOME=/usr/lib/oracle/11.2/client64
    LD_LIBRARY_PATH=${ORACLE_HOME}/lib
  elif [[ -d /usr/lib/oracle/12.1/client64 ]]; then
    ORACLE_HOME=/usr/lib/oracle/12.1/client64
    LD_LIBRARY_PATH=${ORACLE_HOME}/lib
  fi
  echo "export ORACLE_HOME=${ORACLE_HOME}" >> ${LEXHOME}/.bash_profile
  echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib" >> ${LEXHOME}/.bash_profile
  ldconfig
  ;;
esac
## Instalación de  uWSGI
pip install uwsgi
cd ${TMPDIR}
curl -o ${TMPDIR}/node-${NODE}-linux-x64.tar.gz https://nodejs.org/dist/v4.2.6/node-${NODE}-linux-x64.tar.gz
## Instalación de NodeJS y Node modules
cd /usr/local
tar --strip-components=1 \
  -xvzf ${TMPDIR}/node-${NODE}-linux-x64.tar.gz
npm install --loglevel info -g \
  pm2 coffee-script grunt-cli bower gulp
## TODO Need to make it self installable from this point onwards
#su ${LEXUSR}
## LexSys API
#cd ${LEXAPI}
#if [[ -d ${LEXAPI}/ENV ]]; then
#  rm -rf ENV
#fi
#virtualenv ENV
#${LEXAPI}/ENV/bin/pip install -r ${LEXAPI}/requirements.txt
## LexSys Editor
#cd ${LEXEDITOR}
#if [[ -d ${LEXEDITOR}/ENV ]]; then
#  rm -rf ENV
#fi
#virtualenv ENV
#npm install
#bower install
## TODO vi config.json
#grunt assets
## LexSys Portal
#cd ${LEXPORTAL}
#npm install
#bower install
## TODO vi src/js/api/http.js
#grunt assets
## LexSys Desk
#cd ${LEXDESK}
#npm install
## TODO vi src/config.json
#gulp build --env production
# Configuracion de systemd (solo para CentOS 7)
#if [[ $OS_VERSION == *" 7."* ]]
#then
#	sudo cp ${HOME}/deployment_files/systemd/emperor.lexsys.service /etc/systemd/system

	# Iniciar todos los servicio WSGI
#	sudo systemctl start emperor.lexsys.service

	# Registrar servicio para levantar con el inicio del sistema
#	sudo systemctl enable emperor.lexsys.service
#else
#	sudo cp ${HOME}/deployment_files/upstart/emperor.lexsys.conf /etc/init/emperor-lexsys.conf

	# Iniciar servicio
#	sudo initctl start emperor-lexsys
#fi



#-------------------- Servidor proxy ----------------------

# Instalacion de nginx
#sudo yum install nginx -y

# Configuracion de servidores
#sudo cp ${HOME}/deployment_files/nginx/lexsys.conf /etc/nginx/conf.d


#---------------------System Settings-------------------------

# Configuración del firewall (solo para CentOS 7)
#if [[ $OS_VERSION == *" 7."* ]]
#then
#	sudo firewall-cmd --permanent --zone=public --add-port=3002/tcp
#	sudo firewall-cmd --permanent --zone=public --add-service=http
#	sudo firewall-cmd --permanent --zone=public --add-service=https
#	sudo firewall-cmd --permanent --zone=public --add-port=3001/tcp
#	sudo firewall-cmd --permanent --zone=public --add-port=3004/tcp
#	sudo firewall-cmd --reload
	# Inicio del servicio
#	sudo systemctl start nginx
#else

	# Inicio del servicio
#	sudo /etc/init.d/nginx start

#fi


#----------------Comandos CentOS 6---------------

# Iniciar el emperor
# sudo initctl start emperor-lexsys

# Detener el emperor
# sudo initctl stop emperor-lexsys

# Estatus del emperor
# sudo initctl status emperor-lexsys

# Iniciar nginx
# sudo /etc/init.d/nginx start

# Detener nginx
# sudo /etc/init.d/nginx stop

#---------------Comandos CentOS 7---------------

# Iniciar el emperor
# sudo systemctl start emperor.lexsys.service

# Detener el emperor
# sudo systemctl stop emperor.lexsys.service

# Estatus del emperor
# sudo systemctl status emperor.lexsys.service

# Iniciar nginx
# sudo systemctl start nginx

# Detener nginx
# sudo systemctl stop nginx

#-----------------Errores Comunes-----------------


# Error: OID generation failed
# Componente: NN o PS
# Solucion: 
# 1. Ejecutar comando hostname
# 2. Copiar salida del comando anterior al de la linea que inicia con 127.0.0.1 del archivo /etc/hosts
# Referencia: http://chaos667.tumblr.com/post/20006357466/ora-21561-and-oracle-instant-client-112

# Error: libclntsh.so.11.1: cannot open shared object file
# Componente: uwsgi (NN o PS)
# Solucion: 
# 1. Crear el archivo /etc/ld.so.conf.d/oracle64.conf
# 2. Poner la ruta de LD_LIBRARY_PATH en el arvhivo creado
# 3. Ejecutar "sudo ldconfig" para que se actualicen las referencias
