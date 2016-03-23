## LexSys 2 Dockerfile
##
## Build a LexSys container running:
##
##    docker -t lexsys:[tag] .
##
FROM centos:7
MAINTAINER Ernesto Celis <ernesto@tic.uno>

## Bootstrap Operating System
COPY bootstrap.sh ./
#COPY oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
#COPY oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
RUN ./bootstrap.sh ; \
  rm ./*.rpm ; \
  rm /tmp/*.tar.gz ; \
  rm -rf /tmp/npm* ; \
  rm -rf /root/.npm ; \
  yum clean all

WORKDIR /home/lexusr
COPY src/ ./
RUN chown -R lexusr:lexusr ./
USER lexusr
## Build LexSys install
RUN /bin/bash -l deployment/build.sh

CMD ["/bin/bash -l", "/home/lexusr/deployment/run.sh", "start"]

