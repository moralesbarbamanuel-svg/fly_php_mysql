FROM php:8.1-cli

RUN docker-php-ext-install mysqli pdo pdo_mysql

COPY . /app/

WORKDIR /app/src

EXPOSE 3306

CMD ["php", "-S", "0.0.0.0:3306"]
