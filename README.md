# ipfs-install

# 1. go环境安装
## 安装

yum install  golang

## 配置环境变量

#新建go目录作为项目目录
mkdir -p $HOME/go
#用cat的方法在尾部增加配置配置golang的 GOROOT GOPATH

    cat >>$HOME/.bash_profile<<EOF
    export GOROOT=/usr/lib/golang
    export GOPATH=\$HOME/go
    export PATH=\$PATH:\$GOROOT/bin
    EOF

## 让配置生效

    source $HOME/.bash_profile

## 检查下go的env环境变量

    go env

输出：

```
[giser@izbp182lz6444d7n8bnvx4z ipfs]$  go env
GOARCH="amd64"
GOBIN=""
GOCACHE="/home/giser/.cache/go-build"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="linux"
GOOS="linux"
GOPATH="/home/giser/go"
GOPROXY=""
GORACE=""
GOROOT="/usr/lib/golang"
GOTMPDIR=""
GOTOOLDIR="/usr/lib/golang/pkg/tool/linux_amd64"
GCCGO="gccgo"
CC="gcc"
CXX="g++"
CGO_ENABLED="1"
GOMOD=""
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=/tmp/go-build294906065=/tmp/go-build -gno-record-gcc-switches"

```



# 2. 搭建单节点的私有IPFS网络
前面是启动了一个IPFS节点加入了公有IPFS网络，如果你想搭建自己私有的IPFS网络，需要为自己的节点设置swarm key密钥。

## 2.1 生成私有网络swarm key
要生成私有网络的话，必须使用ipfs-swarm-key-gen创建私有网络的swarm key。私有网络的所有的节点都要使用这个key，否则无法加入这个私有网络。

    #关闭前面启动的ipfs节点
    
        docker stop ipfs_host
        docker rm -f ipfs_host
    #配置staging和data的volume映射文件
    
        ipfs_staging=/tmp/ipfs_staging
        mkdir -p $ipfs_staging
        ipfs_data=/tmp/ipfs_data
        mkdir -p $ipfs_data
    #拉取ipfs swarm key工具
    
        go get github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen
    #生成swarm key
    
        $GOPATH/bin/ipfs-swarm-key-gen > $ipfs_data/swarm.key
    #启动ipfs节点
    
        docker run -d --name ipfs_host \
        -v $ipfs_staging:/export \
        -v $ipfs_data:/data/ipfs \
        -p 4001:4001 \
        -p 127.0.0.1:8080:8080 \
        -p 127.0.0.1:5001:5001 \
        ipfs/go-ipfs:latest

## 2.2 移除默认的bootstrap节点
默认配置的节点都是加入全球IPFS网络的，需要删除所有bootstrap节点信息。
【运行命令】

docker exec ipfs_host ipfs bootstrap rm --all

【检查结果】
查看swarm peers，如果打印出的列表为空就对了。

#### 在ipfs_host容器中运行‘ipfs swarm peers’命令，查看已连接的其他ipfs节点

docker exec ipfs_host ipfs swarm peers

# 3. 为私有IPFS网络添加节点
搭建的IPFS如果只有一个节点，可以用作调试环境，但要用于生产环境的话就没有意义了。生产环境最好还是搭建多节点的IPFS网络。
在第2步中，第一个私有节点启动后，可以再添加若干个新的节点，这样一个多节点的IPFS私有网络就搭好了。添加新节点时要注意：1）在添加新节点的之前，要把前面生成的swarm key复制到ipfs_data目录下；2）在新节点启动后，要指定bootstrap信息。

启动第二个IPFS节点（同一台物理机）
在测试环境和生产环境，建议在不同物理机上创建IPFS多节点。在本地调试环境，可以在一台物理机上创建多个IPFS节点。在创建新节点的时候要注意：1）不同节点映射的volume不要重合；2）容器名不要重合；3）对外端口不要重合；4）要记得把前面生产的swarm key复制到新创建的节点的ipfs_data文件夹下。例如：

        new_peer_suffix=_1
        ipfs_staging=/tmp/ipfs_staging$new_peer_suffix
        mkdir -p $ipfs_staging
        ipfs_data=/tmp/ipfs_data$new_peer_suffix
        mkdir -p $ipfs_data
    
        cp /tmp/ipfs_data/swarm.key $ipfs_data/swarm.key
       #启动ipfs节点
        docker run -d --name ipfs_host$new_peer_suffix \
        -v $ipfs_staging:/export \
        -v $ipfs_data:/data/ipfs \
        -p 4101:4001 \
        -p 127.0.0.1:8180:8080 \
        -p 127.0.0.1:5101:5001 \
        ipfs/go-ipfs:latest


在一台物理机上可以启动多个IPFS节点（我自己在macbook pro上创建了3个peer，经测试两两彼此都是联通的），只要注意前面4个注意事项就好了。

指定bootstrap信息(Optional)
ipfs bootstrap add /ip4/x.x.x.x/tcp/4001/ipfs/QmbvgDGNmKRoTiB16g1qn82pTupQdPznZPwVo9zvrCPEJv

# 4. 测试IPFS节点（上传/下载文件）
测试IPFS节点比较简单

上传文件

```
# 登陆到ipfs_host container
docker exec -it ipfs_host /bin/sh
# 上传文件
# 注：测试的时候不建议上传特别大的文件，尤其如果你是连了全球网络的话，也不要上传私密文件.
# 下面的所有命令行都是跑在ipfs_host container里面的
# 创建hello world测试文件
echo "hello world" > hello.txt
ipfs add hello.txt
```


### 【查看结果】方法1: 查看上传进度
上传文件的add命令会打印出上传的进度，如果看到100.00%就是上传完毕了。

/ # ipfs add /data/ipfs/version 
added QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o hello.txt
 12 B / 12 B [===================================================================================================================================] 100.00%

### 【查看结果】方法2: ipfs cat命令查看文件内容

docker exec ipfs_host ipfs cat /ipfs/QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o

一切正常的话应该能看到hello.txt的文件内容：

/ # ipfs cat QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world

### 【查看结果】方法3: 浏览器查看
前面启动ipfs节点的时候把ipfs_host容器的8080端口映射到了物理机，可以通过该端口直接在浏览器中查看刚刚上传的文件内容，直接在浏览器中敲地址http://localhost:8080/ipfs/------IPFS_URL------就可以查看文件了。
例如，刚刚上传的文件hash是QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o，直接在浏览器地址窗口输入
http://localhost:8080/ipfs/QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
就可以看到文件内容了

### 【查看结果】方法4: curl命令访问8080端口
新开一个terminal窗口，运行下面这个命令：

curl http://localhost:8080/ipfs/QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o

打印出来hello world就对了～_～

hello world




# 参考资料
https://blog.csdn.net/oscube/article/details/80598790
https://blog.csdn.net/weixin_41459401/article/details/84563258
https://blog.csdn.net/weixin_41459401/article/details/84582125

