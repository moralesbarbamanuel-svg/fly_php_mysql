FROM php:8.1-apache-alpine

# Instalar MySQL y extensiones
RUN apk add --no-cache mysql mysql-client \
    && docker-php-ext-install pdo pdo_mysql mysqli

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Crear directorios para MySQL
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld

# Copiar archivos
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# Copiar SQL de init
RUN mkdir -p /docker-entrypoint-initdb.d
COPY sql/init.sql /docker-entrypoint-initdb.d/init.sql

WORKDIR /var/www/html

EXPOSE 3000

# Script de inicio
RUN printf "#!/bin/sh\n\
mkdir -p /var/lib/mysql\n\
mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql 2>/dev/null || true\n\
mysqld --user=mysql --bind-address=127.0.0.1 &\n\
MYSQL_PID=\$!\n\
\n\
for i in {1..30}; do\n\
  mysql -u root -e 'SELECT 1' 2>/dev/null && break\n\
  sleep 1\n\
done\n\
\n\
if [ -f /docker-entrypoint-initdb.d/init.sql ]; then\n\
  mysql -u root < /docker-entrypoint-initdb.d/init.sql\n\
fi\n\
\n\
exec apache2-foreground\n" > /entrypoint.sh \
 && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
