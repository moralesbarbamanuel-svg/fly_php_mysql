FROM php:8.1-cli

RUN docker-php-ext-install mysqli pdo pdo_mysql

COPY . /app/

WORKDIR /app/

EXPOSE 3000

CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-3000}"]
