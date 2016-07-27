## LexSys 2 Dockerfile
##
## Build a LexSys container running:
##
##    docker -t lexsys:[tag] .
##
FROM centos:6
MAINTAINER Ernesto Celis <ernesto@tic.uno>

## Bootstrap Operating System
COPY bootstrap.sh ./
COPY oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm /tmp/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
COPY oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm /tmp/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
RUN ./bootstrap.sh ; \
  rm ./*.rpm ; \
  rm /tmp/*.tar.gz ; \
  rm -rf /tmp/npm* ; \
  rm -rf /root/.npm ; \
  yum clean all

#WORKDIR /home/lexusr
#USER lexusr

#CMD ["/home/lexusr/deployment/run.sh", "start"]
