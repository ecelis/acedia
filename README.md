LexSys Deployment
=================


Docker
------


    curl -o lexsys.tar.gz \
      https://github.com/ecelis/acedia/archive/master.tar.gz
    tar -xvzf lexsys.tar.gz
    cd acedia
    docker build -t lexsys .
    docker run -i -t -v $(pwd):/vagrant lexsys:latest /bin/bash


Instalador
----------


    su - lexusr
    /vagrant/makeself/makeself.sh --base64 --notemp --current \
      /tmp/lexinstall_<DB>_<OS>.run
