## LexSys 2

FROM centos:6
MAINTAINER Ernesto Celis <ernesto@tic.uno>

ENV lexdb oracle

COPY bootstrap.sh bootstrap.sh
COPY oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
COPY oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm

RUN '/bootstrap.sh'

CMD ["/bin/bash"]