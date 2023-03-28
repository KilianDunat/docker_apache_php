FROM php:8.1-apache
    
RUN apt update \
    && apt install -y zlib1g-dev g++ git libicu-dev zip libzip-dev zip nano \
    && docker-php-ext-install mysqli intl opcache pdo pdo_mysql \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip

WORKDIR /var/www

RUN git clone https://github.com/Noumaa/MatchJob.git

#RUN cp MatchJob/ /var/www/html

#COPY ./MatchJob /var/www/html

COPY ./apache/000-default.conf /etc/apache2/sites-available

WORKDIR /var/www/MatchJob

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"

RUN php composer-setup.php

RUN php -r "unlink('composer-setup.php');"

RUN mv composer.phar /usr/bin/composer

RUN composer install

RUN php bin/console doctrine:migrations:migrate

RUN a2enmod rewrite