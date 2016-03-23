LexSys Deployment
=================


    git clone git@github.com:ecelis/acedia.git


Docker
------


    docker build -t lexsys .
    docker run -i -t /bin/bash


Instalador
----------


    su - lexusr
    /vagrant/makeself/makeself.sh --base64 --notemp --current \
      $(pwd) /tmp/lexinstall_<DB>_<OS>.run "LexSys 2 <DB> <OS>"


