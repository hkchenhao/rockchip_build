# [Docker Command](https://www.runoob.com/docker/docker-image-usage.html)
- 构建镜像 `docker build -f build_docker.dockerfile -t image_ubuntu:23.04 .`
- 查看镜像 `docker images -a`
- 删除镜像 `docker rmi image_ubuntu:23.04`
    

- 查看容器 `docker ps -a`
- 启动容器 `docker run --name container_ubuntu_23.04 -itd --privileged -v /home/chenhao.0405/Embedded/opensdk_rk3399:/home/ubuntu/opensdk_rk3399 docker.io/library/image_ubuntu:23.04 /bin/bash`
- 启停容器 `docker start/stop <container_id>`
- 进入容器 `docker exec -it <container_id> /bin/bash`
- 删除容器 `docker rm -f <container_id>`