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
pip install virtualenv uwsgi
cd ${TMPDIR}
curl -o ${TMPDIR}/node-${NODE}-linux-x64.tar.gz https://nodejs.org/dist/v4.2.6/node-${NODE}-linux-x64.tar.gz
## Instalación de NodeJS y Node modules
cd /usr/local
tar --strip-components=1 \
  -xvzf ${TMPDIR}/node-${NODE}-linux-x64.tar.gz
npm install --loglevel info -g \
  pm2 coffee-script grunt-cli bower gulp

