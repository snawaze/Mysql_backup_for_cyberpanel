#!/bin/bash
yum -y install gcc make glib2-devel libcurl-devel openssl-devel gmp-devel tar automake autoconf libtool wget asciidoc
wget https://megatools.megous.com/builds/megatools-1.10.0-rc1.tar.gz
tar -xzvf megatools*.tar.gz
cd megatools*
./configure
make
make install