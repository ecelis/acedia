#!/bin/bash
##
## Environment variables default values can be changed at runtime
##
## LEXUSR=someuser LEXHOME=/opt/somedir bootstrap.sh
##
## Get Operating System version
OS_VERSION=$(cat /etc/redhat-release)
## LexSys operating system user
LEXUSR=${LEXUSR:-lexusr}
## BEWARE! uid & gid must be the same as the user who runs the container
LEXGID=${LEXGID:-1001}
LEXUID=${LEXUID:-1001}
## Filesystem path where LexSys will live
LEXHOME=${LEXHOME:-/home/${LEXUSR}}
## Log directory
LOGDIR=${LOGDIR:-${LEXHOME}/log}
## Temporary directory with required packages for install
TMPDIR=${TMPDIR:-/tmp}
## NodeJS version, check http://nodejs.org and choose the stable version
NODE_VERSION=${NODE_VERSION:-v4.5.0}
## Python Version, currently only 2.7 is supported
PYTHON_VERSION=${PYTHON_VERSION:-2.7}

#### DO NOT CHANGE ANYTHING BELOW THIS LINE, UNLESS YOU KNOW WHAT
#### YOU'RE DOING
## RHEL subscription login details
RHUSER=${1}
RHPASS=${2}

## LexSys Modules path
LEXAPI=${LEXHOME}/wrath
LEXEDITOR=${LEXHOME}/EDITOR
LEXDESK=${LEXHOME}/wpride
LEXPORTAL=${LEXHOME}/sloth

## For RHEL systems we should register the host
function register-rhsystem {
  subscription-manager register --username=$1 --password=$2 --auto-attach
  if [[ $OS_VERSION == "Red Hat"*" 6."* ]]; then
    subscription-manager repos --enable rhel-server-rhscl-6-rpms
    subscription-manager repos --enable rhel-6-server-optional-rpms
  elif [[ $OS_VERSION == "Red Hat"*" 7."* ]]; then
    subscription-manager repos --enable rhel-server-rhscl-7-rpms
    subscription-manager repos --enable rhel-7-server-optional-rpms
  fi
}

## Define which EPEL package we'll need depending on the GNU/Linux
## distribution and take the chance to register the system with
## Red Hat if needed
EPEL="epel-release"
if [[ $OS_VERSION == "Red Hat"*" 6."* ]]; then
#  register-rhsystem $RHUSER $RHPASS
  EPEL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm"
elif [[ $OS_VERSION == "Red Hat"*" 7."* ]]; then
  register-rhsystem $RHUSER $RHPASS
  EPEL="https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
fi
## Install Software Collections package
if [[ $OS_VERSION == "CentOS"* ]]; then
  yum -y install centos-release-scl
fi
## Add PostgreSQL repository
if [[ $OS_VERSION == *" 7."* ]]; then
  # CentOS 7 yum install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm -y
  yum -y install http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-2.noarch.rpm
  # Add psql binaries to lexusr PATH
elif [[ $OS_VERSION == *" 6."* ]]; then
  # CentOS 6 http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-2.noarch.rpm
  yum install http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm -y
fi
curl -o /etc/yum.repos.d/patito.repo https://patito.club/yum/patito.repo

## Print bootstrap summary
echo -e "Starting LexSys Install"
echo -e "========================================================================\n\n"
echo -e "Operating system: ${OS_VERSION}"
echo -e "Data base: ${LEXDB}"
echo -e "System username: ${LEXUSR}"
echo -e "Install path: ${LEXHOME}"
echo -e "Log directory: ${LOGDIR}\nNodeJS: ${NODE_VERSION}\n"
echo -e "\n\n"
sleep 5

## Update operating system and add extra YUM repositories
yum install -y ${EPEL}
yum update -y

# LexSys dependencies
if [[ $OS_VERSION == *" 6."* ]]; then
  yum -y install tar gzip make gcc gcc-c++ git xz \
    openssl-devel pcre-devel zlib-devel \
    rh-mongodb26 rh-mongodb26-mongodb-server \
    rh-mongodb26-runtime rh-mongodb26-devel \
    python27 python27-python-devel \
    python27-python-pip python27-python-virtualenv sudo
  . /opt/rh/python27/enable
  echo '. /opt/rh/python27/enable' >> /etc/profile
elif [[ $OS_VERSION == *" 7."* ]]; then
  yum -y install tar gzip make gcc gcc-c++ git xz \
    openssl-devel pcre-devel zlib-devel \
    python-devel python-pip \
    mongodb-org sudo \
    libpqxx libpqxx-devel \
    postgresql94 postgresql94-contrib \
    postgresql94-devel libaio
  yum -y install \
    http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm
fi
yum --disablerepo=epel -y install nginx
## Install Oracle Instant Client
yum -y install http://descarga.lexsys.net/oracle/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
yum -y install http://descarga.lexsys.net/oracle/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
## Install Python virtualenv
easy_install -U setuptools
pip install virtualenv

## Add the LexSys owner
groupadd -g ${LEXGID} ${LEXUSR}
useradd -m -d ${LEXHOME} -u ${LEXUID} -g ${LEXGID} -G wheel ${LEXUSR}

## Setup directories
mkdir -p ${LOGDIR}
chmod 711 ${LEXHOME}
chown -R ${LEXUSR}:${LEXUSR} ${LOGDIR}

## Enable passwordless sudo
echo '%wheel        ALL=(ALL)       NOPASSWD: ALL' >> /etc/sudoers
if [[ -d /usr/lib/oracle/11.2/client64 ]]; then
  # Add psql binaries to lexusr PATH
  echo 'export PATH=/usr/pgsql-9.4/bin:$PATH' >> /etc/profile
  ORACLE_HOME=/usr/lib/oracle/11.2/client64
  LD_LIBRARY_PATH=${ORACLE_HOME}/lib
elif [[ -d /usr/lib/oracle/12.1/client64 ]]; then
  ORACLE_HOME=/usr/lib/oracle/12.1/client64
  LD_LIBRARY_PATH=${ORACLE_HOME}/lib
fi
echo "export ORACLE_HOME=${ORACLE_HOME}" >> /etc/profile
echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib" >> /etc/profile
ldconfig
## Install NodeJS and required npm modules
cd ${TMPDIR}
curl -LO https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz
cd /usr/local
tar --strip-components=1 \
  -xJf ${TMPDIR}/node-${NODE_VERSION}-linux-x64.tar.xz
sleep 5 # Sometimes it fails installing NPM packages, lets wait a moment
/usr/local/bin/npm install -g pm2 coffee-script grunt-cli bower \
  gulp pm2
