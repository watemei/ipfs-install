# 执行顺序

## 首先执行ipfs-install.sh 创建第一个容器ipfs_host

## 依次执行ipfs-new-2-install.sh  ipfs-new-install.sh

## ipfs-install-webui.sh 是为了显示webui单独安装的需要连接全网

可以参见文章：[ipfs私有链部署后webui 404找不到页面的原因](https://blog.csdn.net/wxb880114/article/details/88875612)

## 注意
私有链的key 保持一致 否则 节点添加会失败

## 常用的命令

#### 查询节点
docker exec ipfs_host_1 ipfs swarm peers

#### 添加节点
 docker exec ipfs_host ipfs bootstrap add /ip4/172.17.0.6/tcp/4001/ipfs/QmUnxtTtYqb89g5Snrod6c614VPeJ4B3GyiWJ5LZpKBqeK

#### 查询ipfs节点信息 
docker exec ipfs_host ipfs id

#### 节点是否连通
docker exec ipfs_host ipfs ping QmeoxpCtQ4ZKrbdmWDtnkRXb3CHLuPwTMzX1Vn896aw8T1

#### 进入节点容器
docker exec -it ipfs_host /bin/sh

[ipfs命令大全](https://blog.csdn.net/wxb880114/article/details/88874645)
