# 关闭前面启动的ipfa节点
docker stop ipfs_host_ui
docker rm -f ipfs_host_ui
# 配置staging和data的volume映射文件
ipfs_staging=/tmp/ipfs_staging_ui
mkdir -p $ipfs_staging
ipfs_data=/tmp/ipfs_data_ui
mkdir -p $ipfs_data

# 拉取ipfs swarm key工具
go get github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen
# 生成swarm key
#$GOPATH/bin/ipfs-swarm-key-gen > $ipfs_data/swarm.key

# 启动ipfs节点
docker run -d --name ipfs_host_ui \
-v $ipfs_staging:/export \
-v $ipfs_data:/data/ipfs \
-p 4301:4001 \
-p 8380:8080 \
-p 5301:5001 \
ipfs/go-ipfs:latest
