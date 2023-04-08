FROM debian:stable-20230320


RUN groupadd phpgroup -g 2000
RUN useradd -g 2000 -u 2000 -m -s /bin/bash phpuser

RUN apt-get update -y
RUN apt-get install -y px iputils-ping net-tools iproute2 dnsutils vim file git man
RUN apt-get install -y build-essential wget curl
RUN apt-get install -y pkg-config libxml2-dev libssl-dev libcurl4-openssl-dev libxslt1-dev
RUN apt-get install -y zlib1g-dev libbz2-dev libzip-dev
RUN apt-get install -y libpng-dev libwebp-dev libjpeg-dev libxpm-dev libfreetype6-dev libonig-dev
RUN apt-get install -y libsqlite3-dev libpq-dev 

RUN mkdir -p /srcphp/php8.0 /srcphp/php8.1 /srcphp/php8.2
RUN mkdir -p /app/php8.0 /app/php8.1 /app/php8.2 /app/composer
RUN wget https://www.php.net/distributions/php-8.2.4.tar.gz -O /srcphp/php8.2/php-8.2.4.tar.gz
RUN wget https://www.php.net/distributions/php-8.1.17.tar.gz -O /srcphp/php8.1/php-8.1.17.tar.gz
RUN wget https://www.php.net/distributions/php-8.0.28.tar.gz -O /srcphp/php8.0/php-8.0.28.tar.gz


WORKDIR /srcphp/php8.0/
RUN gunzip -dc php-8.0.28.tar.gz | tar xvf -
WORKDIR /srcphp/php8.1/
RUN gunzip -dc php-8.1.17.tar.gz | tar xvf -
WORKDIR /srcphp/php8.2/
RUN gunzip -dc php-8.2.4.tar.gz | tar xvf -

WORKDIR /srcphp/php8.0/php-8.0.28
RUN ./configure --prefix=/app/php8.0 \
--enable-debug \
--with-config-file-path=/app/php8.0/conf/ \
--with-openssl \
--with-zlib \
--with-bz2 \
--with-curl \
--with-jpeg \
--with-webp \
--with-xpm \
--with-freetype \
--with-gettext \
--with-pdo-mysql \
--with-pdo-pgsql \
--with-xsl \
--with-zip \
--enable-calendar \
--enable-exif \
--enable-gd \
--enable-mbstring \
--enable-soap \
--enable-sockets

RUN make
RUN make install

WORKDIR /srcphp/php8.1/php-8.1.17

RUN ./configure --prefix=/app/php8.1 \
--enable-debug \
--with-config-file-path=/app/php8.1/conf/ \
--with-openssl \
--with-zlib \
--with-bz2 \
--with-curl \
--with-jpeg \
--with-webp \
--with-xpm \
--with-freetype \
--with-gettext \
--with-pdo-mysql \
--with-pdo-pgsql \
--with-xsl \
--with-zip \
--enable-calendar \
--enable-exif \
--enable-gd \
--enable-mbstring \
--enable-soap \
--enable-sockets

RUN make
RUN make install

WORKDIR /srcphp/php8.2/php-8.2.4

RUN ./configure --prefix=/app/php8.2 \
--enable-debug \
--with-config-file-path=/app/php8.2/conf/ \
--with-openssl \
--with-zlib \
--with-bz2 \
--with-curl \
--with-jpeg \
--with-webp \
--with-xpm \
--with-freetype \
--with-gettext \
--with-pdo-mysql \
--with-pdo-pgsql \
--with-xsl \
--with-zip \
--enable-calendar \
--enable-exif \
--enable-gd \
--enable-mbstring \
--enable-soap \
--enable-sockets

RUN make
RUN make install

RUN mkdir -p /app/php8.0/conf/
RUN mkdir -p /app/php8.1/conf/
RUN mkdir -p /app/php8.2/conf/
COPY php.ini /app/php8.0/conf/php.ini
COPY php.ini /app/php8.1/conf/php.ini
COPY php.ini /app/php8.2/conf/php.ini

WORKDIR /app/composer
RUN wget https://getcomposer.org/installer -O composer-setup.php
RUN /app/php8.2/bin/php composer-setup.php --filename composer
RUN rm composer-setup.php

RUN rm -rf /srcphp/*

RUN ln -s /app/php8.2/ /app/php
ARG BIN_PHP=/app/php/bin
ARG BIN_COMPOSER=/app/composer/
ENV PATH=$PATH:$BIN_PHP:$BIN_COMPOSER
WORKDIR /
RUN chown -R phpuser:phpgroup /app

COPY aliases /
COPY env /

RUN cat /aliases >> /root/.bashrc
RUN cat /aliases >> /home/phpuser/.profile
RUN cat /env >> /root/.bashrc
RUN cat /env >> /home/phpuser/.profile
RUN rm /aliases /env
RUN rm -rf /srcphp

