# LexSys Docker Base Image

There are two images, one is the Base Image which holds everything
needed to run all LexSys modules. Currently the Base Image is a CentOS 7
minimal install plus required dependencies to run LexSys.

The Main Image is built based of Base Image and it holds an actual
LexSys install ready to be deployed.


### Build Base Image


    git clone git@github.com:ecelis/acedia.git
    cd acedia
    docker build -t lexsys/base:harley .


* Current release is **Harley Quinn**
