#!/bin/bash

# 检查参数数量
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number_of_nodes>"
    exit 1
fi

# 生成随机 token
TOKEN=$(uuidgen)

# 初始化集群配置
CLUSTER_STATE=new
CLUSTER=""

# 基础端口
BASE_PORT=2379

NUM_ETCD=$(ps aux | grep etcd | grep -v minikube | grep -v grep | wc -l)
if [ $NUM_ETCD -gt 0 ]
then
    echo "The etcd process is running."
    kill -9 $(ps aux | grep etcd | grep -v minikube | grep -v grep | awk '{print $2}')
else
    echo "The etcd process is not running."
fi
rm -rf /tmp/etcd/*

# 创建并启动节点
for ((i=1; i<=$1; i++))
do
    PEER_PORT=$((BASE_PORT + 2 * ($i - 1)))
    CLIENT_PORT=$((PEER_PORT + 1))
    NAME="etcd-node-$i"

    CLUSTER+="$NAME=http://localhost:$PEER_PORT,"
    mkdir -p "/tmp/etcd/${NAME}.etcd"

    echo "$NAME"
done

CLUSTER=${CLUSTER::-1}  # 去掉最后的逗号
ENDPOINTS=""
# 启动节点
for ((i=1; i<=$1; i++))
do
    PEER_PORT=$((BASE_PORT + 2 * ($i - 1)))
    CLIENT_PORT=$((PEER_PORT + 1))
    NAME="etcd-node-$i"

    etcd --data-dir="/tmp/etcd/${NAME}.etcd" --name $NAME \
        --initial-advertise-peer-urls "http://localhost:$PEER_PORT" --listen-peer-urls "http://localhost:$PEER_PORT" \
        --advertise-client-urls "http://localhost:$CLIENT_PORT" --listen-client-urls "http://localhost:$CLIENT_PORT" \
        --initial-cluster $CLUSTER \
        --initial-cluster-state $CLUSTER_STATE --initial-cluster-token $TOKEN >> "/tmp/etcd/${NAME}.log" 2>&1 &
    ENDPOINTS+="localhost:$PEER_PORT,";
done

echo "Etcd cluster started with $1 nodes. Endpoints list = ${ENDPOINTS::-1}"