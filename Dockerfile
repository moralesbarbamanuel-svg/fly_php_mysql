FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=3000

# Instalar paquetes
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    php-pdo \
    libapache2-mod-php \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Apache config
RUN a2enmod rewrite
RUN sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
RUN sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-enabled/000-default.conf

# MySQL dirs
RUN mkdir -p /var/run/mysqld /docker-entrypoint-initdb.d \
 && chown -R mysql:mysql /var/run/mysqld /docker-entrypoint-initdb.d

# Copiar SQL
COPY sql/init.sql /docker-entrypoint-initdb.d/init.sql

# Copiar app
WORKDIR /var/www/html
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Script de inicio
RUN printf "#!/bin/bash\nset -e\n\
echo 'Inicializando MySQL...'\n\
mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql 2>/dev/null || true\n\
\n\
echo 'Iniciando MySQL...'\n\
/usr/sbin/mysqld --user=mysql &\n\
MYSQL_PID=\$!\n\
\n\
echo 'Esperando MySQL...'\n\
for i in {1..30}; do\n\
  if mysql -u root -e 'SELECT 1' &>/dev/null; then\n\
    echo 'MySQL listo'\n\
    break\n\
  fi\n\
  sleep 1\n\
done\n\
\n\
if [ -f /docker-entrypoint-initdb.d/init.sql ]; then\n\
  echo 'Ejecutando init.sql...'\n\
  mysql -u root < /docker-entrypoint-initdb.d/init.sql\n\
fi\n\
\n\
echo 'Iniciando Apache...'\n\
exec /usr/sbin/apache2ctl -D FOREGROUND\n" > /entrypoint.sh \
 && chmod +x /entrypoint.sh

EXPOSE ${PORT}

CMD ["/entrypoint.sh"]
