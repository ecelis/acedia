LexSys Deployment
=================


    git clone git@github.com:ecelis/acedia.git
    git add submodule git@github.com:ecelis/vainglory.git \
      src/deployment
    git add submodule git@github.com:admin-tic/wrath.git \
      src/wrath
    git add submodule git@github.com:admin-tic/wpride.git \
      src/wpride
    git add submodule git@github.com:admin-tic/sloth.git \
      src/sloth
    git add submodule git@github.com:admin-tic/envy.git \
      src/envy


Docker
------


    docker build -t lexsys .
    docker run -i -t /bin/bash


Instalador
----------


    su - lexusr
    /vagrant/makeself/makeself.sh --base64 --notemp --current \
      $(pwd) /tmp/lexinstall_<DB>_<OS>.run "LexSys 2 <DB> <OS>"


nestor
