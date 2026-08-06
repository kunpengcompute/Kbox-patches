# 本文件将基于kbox基础云手机镜像和NEIINT解码相关的二进制制作解码镜像
# 本文件前提是保证已有kbox基础云手机镜像（如kbox:origin）
# 在kbox基础云手机镜像的基础上将NEIINT解码的二进制放入kbox基础云手机镜像中
# 使用docker命令制作解码镜像（如kbox:latest），方便用户使用

# ARG是定义参数名称
# FROM是指定kbox基础云手机镜像
# MAINTAINER是作者名
ARG KBOX_IMAGE
FROM ${KBOX_IMAGE}
LABEL maintainer="root"

COPY ./NETINT/ /NETINT/

# 注意：
# 因为每运行RUN一次就会创建一层镜像，容易产生非常臃肿、非常多层的镜像
# 所以将解码相关的所有二进制整合在一起，保证只运行一次RUN
RUN chmod -R 755 NETINT \
    && chown -R root:root NETINT \
    && cp -pR NETINT/system/* system/ \
    && cp -pR NETINT/vendor/* system/vendor/ \
    && rm -rf NETINT
