FROM php:8.1-cli

RUN docker-php-ext-install mysqli pdo pdo_mysql

COPY . /app/

WORKDIR /app/src

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080"]
