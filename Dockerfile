FROM php:8.2-apache

# Deshabilitar MPM prefork
RUN a2dismod mpm_prefork

# Habilitar MPM event
RUN a2enmod mpm_event

# Instalar MySQL y extensiones
RUN apt-get update && apt-get install -y \
    default-mysql-server \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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

EXPOSE 3306

# Cambiar puerto de Apache a 3306
RUN sed -i 's/Listen 80/Listen 3306/' /etc/apache2/ports.conf

CMD ["apache2-foreground"]
