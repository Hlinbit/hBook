#!/bin/bash
set -x
DATA_PATH=/home/gpadmin/gpdb6_data
if [ $1 == 6 ];then
	DATA_PATH=/home/gpadmin/gpdb6_data
	export GPDATA=/home/gpadmin/gpdb6_data
	source /home/gpadmin/gpdb6/greenplum_path.sh
elif [ $1 == 7 ];then
	DATA_PATH=/home/gpadmin/gpdb7_data
	export GPDATA=/home/gpadmin/gpdb7_data
	source /home/gpadmin/gpdb7/greenplum_path.sh
elif [ $1 == t ];then
	DATA_PATH=/home/gpadmin/gpdb_test_data
	export GPDATA=/home/gpadmin/gpdb_test_data
	source /home/gpadmin/gpdb_test/greenplum_path.sh	
fi

mkdir -p $DATA_PATH
rm -rf $DATA_PATH/*
MASTER_BASE_DIR=$DATA_PATH/master
SEGMENT_BASE_DIR=$DATA_PATH/primary
mkdir -p $MASTER_BASE_DIR
mkdir -p $SEGMENT_BASE_DIR
SEGMENT_BASE_DIRS=" "
SEGMENT_PER_HOST=1
for ((i=0; i<$SEGMENT_PER_HOST; i++))
do
	SEGMENT_BASE_DIRS=" $SEGMENT_BASE_DIR$SEGMENT_BASE_DIRS"
done

cat > init_config <<-EOF
ARRAY_NAME="Greenplum Data Platform"
declare -a DATA_DIRECTORY=($SEGMENT_BASE_DIRS)
SEG_PREFIX=gpseg
PORT_BASE=7000
MASTER_HOSTNAME=$(hostname)
MASTER_PORT=${PGPORT}
MASTER_DIRECTORY=$MASTER_BASE_DIR
TRUSTED_SHELL=ssh
ENCODING=UNICODE

EOF

echo $(hostname) > hosts

gpinitsystem -a -c init_config -h hosts
set +x
source ~/.bashrc
