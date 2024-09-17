# Start with Alpine Linux
FROM alpine:latest
LABEL maintainer="itsmikita@gmail.com"
LABEL description="Lightweight 'LAMP' built on Alipne, so basically 'AAMP'"

# Install necessary packages
RUN apk add --no-cache \
    apache2 \
    php83 \
    php83-apache2 \
    php83-mysqli \
    php83-json \
    php83-openssl \
    php83-curl \
    php83-zlib \
    php83-xml \
    php83-phar \
    php83-intl \
    php83-dom \
    php83-xmlreader \
    php83-ctype \
    php83-session \
    php83-mbstring \
    php83-gd \
    mariadb \
    mariadb-client

# Configure Apache
RUN sed -i 's#AllowOverride None#AllowOverride All#' /etc/apache2/httpd.conf
#    sed -i 's#^DocumentRoot ".*#DocumentRoot "/var/www/html"#g' /etc/apache2/httpd.conf && \
#    sed -i 's#^Directory ".*#Directory "/var/www/html"#g' /etc/apache2/httpd.conf && \
#    sed -i 's#^ServerSignature On#ServerSignature Off#g' /etc/apache2/httpd.conf && \
#    sed -i 's#^ServerTokens OS#ServerTokens Prod#g' /etc/apache2/httpd.conf

# Enable Apache modules
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule expires_module/LoadModule expires_module/' /etc/apache2/httpd.conf

# Create directory for Apache pid file
RUN mkdir -p /run/apache2

# Set working directory
WORKDIR /var/www/localhost/htdocs

# Environment variables for MariaDB
ENV MYSQL_ROOT_PASSWORD=root_password
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=password
ENV MYSQL_DATABASE=user_database

# Initialize MariaDB and create user and database
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    /usr/bin/mysqld --user=mysql --bootstrap <<EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Configure MariaDB to allow connetions from IP
RUN sed -i 's/^skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i 's/^#bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf

# Expose ports
EXPOSE 3306 80

# Expose folders
VOLUME /var/www/localhost/htdocs
VOLUME /var/lib/mysql

# Start Apache and MariaDB
CMD /usr/bin/mysqld_safe --datadir=/var/lib/mysql & \
    httpd -D FOREGROUND