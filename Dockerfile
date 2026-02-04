FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=3000

# -------------------------
# Instalar paquetes
# -------------------------
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    php-pdo \
    libapache2-mod-php \
    supervisor \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Apache config
# -------------------------
RUN a2enmod rewrite
RUN a2enmod php8.1
RUN sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf \
 && sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-enabled/000-default.conf

# -------------------------
# MySQL dirs
# -------------------------
RUN mkdir -p /var/run/mysqld /docker-entrypoint-initdb.d \
 && chown -R mysql:mysql /var/run/mysqld /docker-entrypoint-initdb.d

# -------------------------
# Copiar SQL de init
# -------------------------
COPY sql/init.sql /docker-entrypoint-initdb.d/init.sql

# -------------------------
# Copiar app
# -------------------------
WORKDIR /var/www/html
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

# -------------------------
# Script de inicio
# -------------------------
RUN printf "#!/bin/bash\n\
set -e\n\
\n\
# Inicializar MySQL\n\
if [ ! -d /var/lib/mysql/mysql ]; then\n\
  echo 'Inicializando MySQL...'\n\
  mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql\n\
fi\n\
\n\
# Iniciar MySQL en background\n\
/usr/sbin/mysqld --user=mysql &\n\
MYSQL_PID=\$!\n\
\n\
# Esperar a que MySQL esté listo\n\
echo 'Esperando a que MySQL inicie...'\n\
for i in {1..30}; do\n\
  if mysql -u root -e 'SELECT 1' &>/dev/null; then\n\
    echo 'MySQL está listo'\n\
    break\n\
  fi\n\
  sleep 1\n\
done\n\
\n\
# Ejecutar init.sql si existe\n\
if [ -f /docker-entrypoint-initdb.d/init.sql ]; then\n\
  echo 'Ejecutando init.sql...'\n\
  mysql -u root < /docker-entrypoint-initdb.d/init.sql\n\
fi\n\
\n\
# Iniciar Apache en foreground\n\
exec /usr/sbin/apache2ctl -D FOREGROUND\n" > /usr/local/bin/docker-entrypoint.sh \
 && chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE ${PORT}

CMD ["/usr/local/bin/docker-entrypoint.sh"]
