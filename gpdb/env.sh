alias killpostgres='pgrep postgres | xargs kill -9 && rm -rf /tmp/.s.*'
source scl_source enable devtoolset-7
export MASTER_DATA_DIRECTORY=${GPDATA}/master/gpseg-1
export PATH=$PATH:/usr/bin
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig:/usr/lib64/
alias source7='source /home/gpadmin/gpdb7/greenplum_path.sh && export GPDATA=/home/gpadmin/gpdb7_data && source ~/.bashrc'
alias sourcem='source /home/gpadmin/gpdb_master/greenplum_path.sh && export GPDATA=/home/gpadmin/gpdb7_data && source ~/.bashrc'
alias source6='source /home/gpadmin/gpdb6/greenplum_path.sh && export GPDATA=/home/gpadmin/gpdb6_data && source ~/.bashrc'
alias sourcetest='source /home/gpadmin/gpdb_test/greenplum_path.sh && export GPDATA=/home/gpadmin/gpdb_test_data && source ~/.bashrc'
export PGHOST="localhost.localdomain"
alias deploy_gpdb7='source /home/gpadmin/gpdb7/greenplum_path.sh && source /home/gpadmin/deploy_gpdb.sh 7'
alias deploy_gpdb6='source /home/gpadmin/gpdb6/greenplum_path.sh && source /home/gpadmin/deploy_gpdb.sh 6'
alias deploy_gpdbt='source /home/gpadmin/gpdb_test/greenplum_path.sh && source /home/gpadmin/deploy_gpdb.sh t'
alias config6='./configure --with-perl --with-python --with-libxml --with-gssapi --disable-orca --enable-debug --with-openssl CFLAGS="-O0" --prefix=/home/gpadmin/gpdb6 &&  make -j | grep "warning:" &&  make install'
alias config7='./configure --with-perl --with-python --with-libxml --with-gssapi --disable-orca --enable-debug --with-openssl CFLAGS="-O0" --prefix=/home/gpadmin/gpdb7 &&  make -j | grep "warning:" &&  make install'
alias configo7='./configure --with-perl --with-python --with-libxml --with-gssapi --disable-orca --disable-cassert --with-openssl CXXFLAGS="-O3 -march=native" CFLAGS="-O3 -march=native" --prefix=/home/gpadmin/gpdb7 &&  make -j | grep "warning:" &&  make install'
alias configo6='./configure --with-perl --with-python --with-libxml --with-gssapi --disable-orca --disable-cassert --with-openssl CXXFLAGS="-O3 -march=native" CFLAGS="-O3 -march=native" --prefix=/home/gpadmin/gpdb6 &&  make -j | grep "warning:" &&  make install'
alias configt='./configure --with-perl --with-python --with-libxml --with-gssapi --disable-orca --enable-debug --with-openssl CFLAGS="-O0" --prefix=/home/gpadmin/gpdb_test &&  make -j | grep "warning:" &&  make install'
alias ll='ls -la --color=auto'
alias ls='ls --color=auto'