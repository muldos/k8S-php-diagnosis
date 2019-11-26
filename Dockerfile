FROM php:7.3-apache

MAINTAINER David ROBIN <david.a.robin@gmail.com>

# to avoid time lag in container
ENV TZ Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone \
	&& dpkg-reconfigure -f noninteractive tzdata

# Modify UID & GID of www-data into UID  & GID of the docker's host local user.
# ideally you pass the ARG from docker-compose, using the $UID envvar of
# the docker host
ARG WWW_UID=33
RUN usermod -u ${WWW_UID} www-data && groupmod -g ${WWW_UID} www-data
# PHP's extensions and system's libraries
RUN set -ex; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
	    git \
	    nano \
	    cron \
	    wget \
		unzip \
	    netcat \
		zlib1g-dev \
		libicu63 \
		libjpeg62-turbo-dev \
		libfreetype6-dev \
		libz-dev \
		libmemcached-dev \
		libpng-dev \
		libpq-dev \
		libicu-dev \
		libxml2-dev \
        libzip-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		intl \
		exif \
		pdo \
		pdo_mysql \
		mysqli \
		soap \
		fileinfo \
		intl \
		opcache \
		zip \
	; \
	pecl install memcached-3.1.3 \
    #&& pecl install xdebug-2.7.2 \
    && docker-php-ext-enable memcached \
	#&& docker-php-ext-enable xdebug \
    ; \
# cleaning build dependencies
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	apt-mark manual git; \
	apt-mark manual cron; \
	apt-mark manual wget; \
	apt-mark manual unzip; \
	apt-mark manual netcat; \
	apt-mark manual nano; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*
RUN apache2-foreground -k stop
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
ENV APACHE_DOCUMENT_ROOT /var/www/html/web

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY conf/app.ini /usr/local/etc/php/conf.d/app.ini
#COPY conf/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# see https://secure.php.net/manual/en/opcache.installation.php
COPY conf/opcache-recommended.ini /usr/local/etc/php/conf.d/opcache-recommended.ini
# installation de composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
RUN chown -R www-data /var/www && chgrp -R www-data /var/www
# add drush and drupal console to PATH
ENV PATH /var/www/html/vendor/bin:$PATH
# environment variable to use in your php application
ENV PHP_APPLICATION_ENV dev
EXPOSE 80

CMD ["apache2-foreground"]
