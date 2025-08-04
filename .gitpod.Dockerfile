FROM gitpod/workspace-full

USER root

RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    libapache2-mod-php \
    unzip \
    wget \
    && systemctl enable mysql

USER gitpod
