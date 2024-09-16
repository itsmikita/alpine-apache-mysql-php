# Start with Alpine Linux
FROM alpine:latest
LABEL maintainer="itsmikita@gmail.com"
LABEL description="Lightweight 'LAMP' built on Alipne, so basically 'AAMP'"

# Install necessary packages
RUN apk add --no-cache \
    apache2 \
    php83 \
    php83-apache2 \
    php83-common \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-gd \
    php83-intl \
    php83-json \
    php83-mbstring \
    php83-mysqli \
    php83-openssl \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    php83-phar \
    php83-session \
    php83-xml \
    php83-xmlreader \
    php83-zlib \
    mariadb \
    mariadb-client

# Configure Apache
RUN sed -i 's#^DocumentRoot ".*#DocumentRoot "/var/www/html"#g' /etc/apache2/httpd.conf && \
    sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/httpd.conf && \
    sed -i 's#^ServerSignature On#ServerSignature Off#g' /etc/apache2/httpd.conf && \
    sed -i 's#^ServerTokens OS#ServerTokens Prod#g' /etc/apache2/httpd.conf

# Enable Apache modules
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule expires_module/LoadModule expires_module/' /etc/apache2/httpd.conf

# Create directory for Apache pid file
RUN mkdir -p /run/apache2

# Set working directory
WORKDIR /var/www/html

# Environment variables for MariaDB
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=mydatabase

# Initialize MariaDB and create database
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    /usr/bin/mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO 'root'@'localhost';
EOF

# Expose directories
VOLUME /var/www/html
VOLUME /var/lib/mysql

# Expose ports
EXPOSE 80 3306

# Start Apache and MariaDB
CMD /usr/bin/mysqld_safe --datadir=/var/lib/mysql & \
    httpd -D FOREGROUND