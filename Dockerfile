FROM ubuntu:18.04

MAINTAINER Sysdig <support@sysdig.com>

ENV FALCO_REPOSITORY dev

LABEL RUN="docker run -i -t --privileged -v /var/run/docker.sock:/host/var/run/docker.sock -v /dev:/host/dev -v /proc:/host/proc:ro -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro -v /usr:/host/usr:ro --name NAME IMAGE"

ENV SYSDIG_HOST_ROOT /host

ENV HOME /root

RUN cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
	bash-completion \
	curl \
	dkms \
	jq \
	gnupg2 \
	ca-certificates \
	gcc \
	gcc-5 && rm -rf /var/lib/apt/lists/*

# Since our base Debian image ships with GCC 5.0 which breaks older kernels, revert the
# default to gcc-5. Also, since some customers use some very old distributions whose kernel
# makefile is hardcoded for gcc-4.6 or so (e.g. Debian Wheezy), we pretend to have gcc 4.6/4.7
# by symlinking it to 5

RUN rm -rf /usr/bin/gcc \
 && ln -s /usr/bin/gcc-5 /usr/bin/gcc \
 && ln -s /usr/bin/gcc-5 /usr/bin/gcc-4.9 \
 && ln -s /usr/bin/gcc-5 /usr/bin/gcc-4.8 \
 && ln -s /usr/bin/gcc-5 /usr/bin/gcc-4.7 \
 && ln -s /usr/bin/gcc-5 /usr/bin/gcc-4.6

COPY ./falco-0.9.0-1-x86_64.deb /

RUN dpkg -i /falco-0.9.0-1-x86_64.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN ln -s $SYSDIG_HOST_ROOT/lib/modules /lib/modules

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/falco"]
