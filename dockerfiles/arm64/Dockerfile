#Dockerfile for tf-k8s-launcher

FROM docker.io/yashindane/tf-k8s-launcher-base-arm:v1

MAINTAINER Yash Indane <yashindane46@gmail.com>

COPY . /tf-launch/

WORKDIR /tf-launch

ENTRYPOINT ["sh", "launch_entrypoint.sh"]
