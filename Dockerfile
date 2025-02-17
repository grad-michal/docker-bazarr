FROM lsiobase/alpine.python:3.9

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BAZARR_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

RUN \
echo "**** install packages ****" && \
 apk add --no-cache \
	py-gevent && \
 echo "**** install bazarr ****" && \
 if [ -z ${BAZARR_VERSION+x} ]; then \
	BAZARR_VERSION=$(curl -sX GET "https://api.github.com/repos/grad-michal/bazarr/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/bazarr.tar.gz -L \
	"https://github.com/grad-michal/bazarr/archive/${BAZARR_VERSION}.tar.gz" && \
 mkdir -p \
	/app/bazarr && \
 tar xf \
 /tmp/bazarr.tar.gz -C \
	/app/bazarr --strip-components=1 && \
 echo "**** fix backports warning in log ****" && \
 if [ ! -e /usr/lib/python2.7/site-packages/backports/__init__.py ]; \
	then \
 	touch /usr/lib/python2.7/site-packages/backports/__init__.py ; \
 fi && \
 rm -rf \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 6767
VOLUME /config /movies /tv
