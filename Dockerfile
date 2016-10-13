## LexSys 2 Dockerfile
##
## Build a LexSys base container running:
##
##    docker -t lexsys:base[:tag] .
##
FROM centos:7
MAINTAINER Ernesto Celis <ernesto@tic.uno>

## Bootstrap Operating System
COPY src /
RUN ./bootstrap.sh ; \
  rm /tmp/*.rpm ; \
  rm /tmp/*.tar.?z ; \
  rm -rf /tmp/npm* ; \
  rm -rf /root/.npm ; \
  yum clean all
