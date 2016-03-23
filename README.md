LexSys Deployment
=================


    git clone git@github.com:ecelis/acedia.git


Docker
------

### Build

`basename` identifica el ambiente base, por ejemplo Cliente A corre
RHEL 6 con Oracle y Cliente B corre CentOS 7 con PostgreSQL, podemos
construir imagenenes base `lexsys/cliente_a` y `lexsys/cliente_b`.

`build` identifica la fecha en que se hizo el build, puede servir como
referencia para release minor version. El formato es 2 dígitos del año,
2 dígitos del mes, 2 dígitos del día. Ej. 160321. Si es Necesario hacer
más de un buld por día, puede agregarse 2 dígitos de hora y 2 dígitos de
minutos. 160320945


    docker build -t lexsys/<basename>:<build> .


### Run


    docker run --name <ambiente_a> \
      -P -p 22 -p 80 -p 443 -p 3000 -p 3002 -p 3003 -p 3004 -p 3006
      -v $HOME:/home/lexusr



Instalador
----------


    su - lexusr
    /vagrant/makeself/makeself.sh --base64 --notemp --current \
      $(pwd) /tmp/lexinstall_<DB>_<OS>.run "LexSys 2 <DB> <OS>"


