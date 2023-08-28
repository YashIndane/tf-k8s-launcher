#Dockerfile for tf-k8s-launcher

FROM docker.io/yashindane/tf-k8s-launcher-base:v1

MAINTAINER Yash Indane <yashindane46@gmail.com>

LABEL org.opencontainers.image.source https://github.com/yashindane/tf-k8s-launcher

COPY . /tf-launch/

WORKDIR /tf-launch

ENTRYPOINT ["sh", "launch_entrypoint.sh"]
