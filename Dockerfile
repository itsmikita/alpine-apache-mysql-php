# Start with Alpine Linux
FROM alpine:latest

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
    php83-gd

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

# Expose ports
EXPOSE 3306 80

# Expose folders
VOLUME /var/www/localhost/htdocs

# Start Apache and MariaDB
CMD httpd -D FOREGROUND