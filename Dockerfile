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
#ADD http://descarga.lexsys.net/oracle/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm /tmp
#ADD http://descarga.lexsys.net/oracle/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm /tmp
RUN ./bootstrap.sh ; \
  rm /tmp/*.rpm ; \
  rm /tmp/*.tar.?z ; \
  rm -rf /tmp/npm* ; \
  rm -rf /root/.npm ; \
  yum clean all
