FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

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
RUN mkdir -p /var/run/mysqld /docker-entrypoint-initdb.d \
 && chown -R mysql:mysql /var/run/mysqld /docker-entrypoint-initdb.d

# -------------------------
# Copiar SQL de init
# -------------------------
COPY sql/init.sql /docker-entrypoint-initdb.d/init.sql

# -------------------------
# Supervisor config
# -------------------------
RUN mkdir -p /etc/supervisor/conf.d

RUN printf "[supervisord]\nnodaemon=true\n\n\
[program:mysql]\n\
command=/usr/sbin/mysqld\n\
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

# -------------------------
# Script de init MySQL
# -------------------------
RUN printf "#!/bin/bash\n\
set -e\n\
if [ ! -d /var/lib/mysql/mysql ]; then\n\
  echo 'Inicializando MySQL...'\n\
  mysqld --initialize-insecure --user=mysql\n\
  mysqld --skip-networking &\n\
  pid=$!\n\
  until mysqladmin ping --silent; do sleep 1; done\n\
  mysql < /docker-entrypoint-initdb.d/init.sql\n\
  mysqladmin shutdown\n\
fi\n" > /usr/local/bin/mysql-init.sh \
 && chmod +x /usr/local/bin/mysql-init.sh

# -------------------------
# Wrapper de MySQL
# -------------------------
RUN printf "#!/bin/bash\n\
/usr/local/bin/mysql-init.sh\n\
exec /usr/sbin/mysqld\n" > /usr/local/bin/mysql-start.sh \
 && chmod +x /usr/local/bin/mysql-start.sh

# -------------------------
# Actualizar Supervisor para usar wrapper
# -------------------------
RUN sed -i "s|/usr/sbin/mysqld|/usr/local/bin/mysql-start.sh|" \
 /etc/supervisor/conf.d/supervisord.conf

# -------------------------
# App
# -------------------------
WORKDIR /var/www/html

COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 8080

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
