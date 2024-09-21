FROM php:8.0-apache

RUN docker-php-ext-install mysqli

COPY ./src /var/www/html/

RUN chown -R www-data:www-data /var/www/html
