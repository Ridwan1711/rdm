# Dockerfile untuk RDM (Rapor Digital Madrasah)
# Syarat: PHP 7.2, ionCube Loader PHP 7.2, allow_url_fopen, CURL

FROM php:7.2-apache

# Set working directory
WORKDIR /var/www/html

# Install system dependencies dan extensions
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    gd \
    intl \
    zip \
    xml \
    soap

# Install ionCube Loader untuk PHP 7.2
RUN cd /tmp \
    && wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xzf ioncube_loaders_lin_x86-64.tar.gz \
    && PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") \
    && PHP_EXT_DIR=$(php-config --extension-dir) \
    && cp "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" "${PHP_EXT_DIR}/ioncube.so" \
    && echo "zend_extension=ioncube.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && rm -rf /tmp/ioncube*

# Enable PHP extensions dan settings
RUN docker-php-ext-enable curl \
    && echo "extension=curl.so" >> /usr/local/etc/php/php.ini

# Configure PHP settings
RUN echo "allow_url_fopen = On" >> /usr/local/etc/php/php.ini \
    && echo "memory_limit = 512M" >> /usr/local/etc/php/php.ini \
    && echo "upload_max_filesize = 512M" >> /usr/local/etc/php/php.ini \
    && echo "post_max_size = 512M" >> /usr/local/etc/php/php.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/php.ini \
    && echo "max_input_time = 600" >> /usr/local/etc/php/php.ini \
    && echo "max_input_vars = 1000" >> /usr/local/etc/php/php.ini

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Copy application files
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/application/cache \
    && chmod -R 777 /var/www/html/application/logs

# Apache configuration untuk CodeIgniter
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        Options Indexes FollowSymLinks\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

CMD ["apache2-foreground"]
