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
LEXDB=${LEXDB:-postgresql}
## Usuario
LEXUSR=${LEXUSR:-lexusr}
## OJO! uid & gid deben coincidir con los valores del usuario que
## ejecutará el contenedor docker
LEXGID=${LEXGID:-1001}
LEXUID=${LEXUID:-1001}
## Se declara la ruta base de la instalación
LEXHOME=${LEXHOME:-/home}/${LEXUSR}
## Directorio de logs
LOGDIR=${LOGDIR:-/var/log/lexsys}
## Directorio temporal donde se encuentran paquetes binarios requeridos
TMPDIR=${TMPDIR:-/tmp}
## NodeJS
NODE_VERSION=${NODE_VERSION:-v4.2.6}
## Python Version
PYTHON_VERSION=${PYTHON_VERSION:-2.7}

#### NO CAMBIE NADA A PARTIR DE ESTA LINEA SIN SABER EXACTAMENTE LO QUE HACE
## LexSys Modules
LEXAPI=${LEXHOME}/wrath
LEXEDITOR=${LEXHOME}/EDITOR
LEXDESK=${LEXHOME}/wpride
LEXPORTAL=${LEXHOME}/sloth
LEXURL="http://download.lexsys.net/"
if [[ $OS_VERSION == *" 7."* ]]; then
  NGINXURL=${LEXURL}/el7/nginx-1.8.0-TIC.1.el7.centos.ngx.x86_64.rpm
elif [[ $OS_VERSION == *" 6."* ]]; then
  NGINXURL=${LEXURL}/el6/nginx-1.8.0-TIC.1.el6.ngx.x86_64.rpm
fi
## Repositorios de terceros
if [[ $OS_VERSION == "Red Hat"*" 6."* ]]; then
  # EPEL
  EPEL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm"
  # Python 2.7
  #sh -c 'wget -qO- http://people.redhat.com/bkabrda/scl_python27.repo >> /etc/yum.repos.d/scl.repo'
  subscription-manager repos --enable rhel-server-rhscl-6-rpms
  subscription-manager repos --enable rhel-6-server-optional-rpms
elif [[ $OS_VERSION == "Red Hat"*" 7."* ]]; then
  EPEL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
  subscription-manager repos --enable rhel-server-rhscl-7-rpms
  subscription-manager repos --enable rhel-7-server-optional-rpms
else
  EPEL="epel-release"
  yum -y install centos-release-scl
fi
##
echo -e "Iniciando instalación LexSys\n"
echo -e "Sistema Operativo: ${OS_VERSION}\nBase de Datos: ${LEXDB}"
echo -e "Usuario: ${LEXUSR}\nDirectorio: ${LEXHOME}"
echo -e "Logs: ${LOGDIR}\nuWSGI: ${UWSGI}\nNodeJS: ${NODE_VERSION}\n"
sleep 5
## Crear usuario dueño
groupadd -g ${LEXGID} ${LEXUSR}
useradd -m -d ${LEXHOME} -u ${LEXUID} -g ${LEXGID} -G wheel ${LEXUSR}
## Crear Directorios
mkdir -p ${LOGDIR}
chmod 711 ${LEXHOME}
chown -R ${LEXUSR}:${LEXUSR} ${LOGDIR}
## Actualizacion del SO e instalación de repositorios de YUM extra
yum update -y
yum install -y ${EPEL}
## nginx
yum -y install ${NGINXURL}
# LexSys dependencias
if [[ $OS_VERSION == *" 7."* ]]; then
  yum -y install tar gzip make gcc gcc-c++ git \
    openssl-devel pcre-devel zlib-devel \
    python-devel python-pip \
    mongodb mongodb-server mongodb-devel
  yum -y install \
    http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm
  easy_install -U setuptools
  pip install virtualenv uwsgi
fi
#if [[ $OS_VERSION == "CentOS"*" 6."* ]]; then
#   yum -y install tar gzip make gcc gcc-c++ git \
#    openssl-devel pcre-devel zlib-devel \
#    rh-mongodb26 rh-mongodb26-mongo-server \
#    rh-mongodb26-mongo-runtime rh-mongodb26-mongo-devel \
#    python27 python27-python-devel \
#    python27-python-pip python27-python-virtualenv
#fi
if [[ $OS_VERSION == *" 6."* ]]; then
  yum -y install tar gzip make gcc gcc-c++ git \
    openssl-devel pcre-devel zlib-devel \
    rh-mongodb26 rh-mongodb26-mongodb-server \
    rh-mongodb26-mongodb-runtime rh-mongodb26-mongodb-devel \
    python27 python27-python-devel \
    python27-python-pip python27-python-virtualenv
  #scl enable python27 'easy_install-2.7 -U setuptools'
  #scl enable python27 'easy_install-2.7 pip'
  #scl enable python27 'pip2.7 install virtualenv uwsgi'
  . /opt/rh/python27/enable
  echo '. /opt/rh/python27/enable' >> ${LEXHOME}/.bashrc
  easy_install -U setuptools
  pip install uwsgi
  # Add SCL binaries to lexusr PATH
fi
## Instala wkhtmltopdf
yum -y install \
  http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos6-amd64.rpm
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
#yum -y install supervisor
cd ${TMPDIR}
curl -o ${TMPDIR}/node-${NODE_VERSION}-linux-x64.tar.gz https://nodejs.org/dist/v4.2.6/node-${NODE_VERSION}-linux-x64.tar.gz
## Instalación de NodeJS y Node modules
cd /usr/local
tar --strip-components=1 \
  -xvzf ${TMPDIR}/node-${NODE_VERSION}-linux-x64.tar.gz
npm install --loglevel info -g \
  pm2 coffee-script grunt-cli bower gulp

## La siguiente debe ser la última línea del script
#exit 0
