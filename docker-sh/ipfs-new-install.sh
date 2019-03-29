new_peer_suffix=_1
ipfs_staging=/tmp/ipfs_staging$new_peer_suffix
mkdir -p $ipfs_staging
ipfs_data=/tmp/ipfs_data$new_peer_suffix
mkdir -p $ipfs_data

cp /tmp/ipfs_data/swarm.key $ipfs_data/swarm.key

# 启动ipfs节点
docker run -d --name ipfs_host$new_peer_suffix \
-v $ipfs_staging:/export \
-v $ipfs_data:/data/ipfs \
-p 4101:4001 \
-p 127.0.0.1:8180:8080 \
-p 127.0.0.1:5101:5001 \
ipfs/go-ipfs:latest

