FROM ubuntu:14.04
MAINTAINER Mike Ryan <falter@gmail.com>

RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y wget ca-certificates && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN gpg --keyserver pgp.mit.edu --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN	wget --quiet -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget --quiet -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# This directory holds scripts that will be executed prior to dropping 
# privileges.
ENV ENTRYPOINT_CMD_PATH /etc/docker-entrypoint/commands.d
ENV ENTRYPOINT_PRE_PATH /etc/docker-entrypoint/pre.d
RUN mkdir -p /etc/docker-entrypoint/commands.d
RUN mkdir -p /etc/docker-entrypoint/pre.d

ENV ENTRYPOINT_DROP_PRIVS 0
# Not defining ENTRYPOINT_USER here.

ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD commands/show-env.sh /etc/docker-entrypoint/commands.d/show-env
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "help" ]
