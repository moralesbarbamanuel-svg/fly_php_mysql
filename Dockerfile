FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

# -------------------------
# Variables de entorno para MySQL
# -------------------------
ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=app_db
ENV MYSQL_USER=app_user
ENV MYSQL_PASSWORD=app_pass

# -------------------------
# Instalar paquetes
# -------------------------
RUN apt-get update && apt-get install -y \
    apache2 \
    mysql-server \
    php \
    php-mysql \
    libapache2-mod-php \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Apache
# -------------------------
RUN a2enmod rewrite
RUN sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf \
 && sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-enabled/000-default.conf

# -------------------------
# MySQL dirs
# -------------------------
RUN mkdir -p /var/run/mysqld /var/lib/mysql /docker-entrypoint-initdb.d \
 && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql /docker-entrypoint-initdb.d

# -------------------------
# Copiar SQL de inicialización y código PHP
# -------------------------
COPY sql/init.sql /docker-entrypoint-initdb.d/init.sql
COPY src/ /var/www/html/
RUN chown -R www-data:www-data /var/www/html

# -------------------------
# Script de inicialización de MySQL usando variables de entorno
# -------------------------
RUN printf "#!/bin/bash\n\
set -e\n\
if [ ! -d /var/lib/mysql/mysql ]; then\n\
  echo 'Inicializando MySQL...'\n\
  mysqld --initialize-insecure --user=mysql\n\
  mysqld --skip-networking &\n\
  pid=\$!\n\
  until mysqladmin ping --silent; do sleep 1; done\n\
  mysql -u root <<EOF\n\
CREATE DATABASE IF NOT EXISTS \${MYSQL_DATABASE};\n\
CREATE USER IF NOT EXISTS '\${MYSQL_USER}'@'%' IDENTIFIED BY '\${MYSQL_PASSWORD}';\n\
GRANT ALL PRIVILEGES ON \${MYSQL_DATABASE}.* TO '\${MYSQL_USER}'@'%';\n\
FLUSH PRIVILEGES;\n\
EOF\n\
  # Ejecutar init.sql si existe\n\
  if [ -f /docker-entrypoint-initdb.d/init.sql ]; then\n\
    mysql -u root \${MYSQL_DATABASE} < /docker-entrypoint-initdb.d/init.sql\n\
  fi\n\
  mysqladmin shutdown\n\
fi\n" > /usr/local/bin/mysql-init.sh \
 && chmod +x /usr/local/bin/mysql-init.sh

# -------------------------
# Wrapper para Supervisor
# -------------------------
RUN printf "#!/bin/bash\n\
/usr/local/bin/mysql-init.sh\n\
exec /usr/sbin/mysqld\n" > /usr/local/bin/mysql-start.sh \
 && chmod +x /usr/local/bin/mysql-start.sh

# -------------------------
# Configuración de Supervisor
# -------------------------
RUN mkdir -p /etc/supervisor/conf.d

RUN printf "[supervisord]\nnodaemon=true\n\n\
[program:mysql]\n\
command=/usr/local/bin/mysql-start.sh\n\
user=mysql\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stderr_logfile=/dev/stderr\n\n\
[program:apache]\n\
command=/usr/sbin/apachectl -D FOREGROUND\n\
autorestart=true\n\
stdout_logfile=/dev/stdout\n\
stderr_logfile=/dev/stderr\n" \
> /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
