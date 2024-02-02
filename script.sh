#!/bin/bash

# Verificar si se ejecuta como superusuario
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, ejecuta este script como superusuario."
    exit
fi

# Actualizar repositorios e instalar Apache
apt-get update
apt-get install -y apache2

# Instalar PHP y módulos necesarios para WordPress
apt-get install -y php libapache2-mod-php php-mysql

# Descargar e instalar MySQL (MariaDB) y configurar contraseña root
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password password system"
debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password_again password system"
apt-get install -y mariadb-server

# Crear base de datos y usuario para WordPress
mysql -u root -p"your_root_password" -e "CREATE DATABASE wordpress;"
mysql -u root -p"your_root_password" -e "CREATE USER 'system'@'localhost' IDENTIFIED BY 'system';"
mysql -u root -p"your_root_password" -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'system'@'localhost';"
mysql -u root -p"your_root_password" -e "FLUSH PRIVILEGES;"

# Descargar e instalar WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

# Configurar Apache para WordPress
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
echo "ServerName localhost" >> /etc/apache2/sites-available/wordpress.conf
echo "DocumentRoot /var/www/html/wordpress" >> /etc/apache2/sites-available/wordpress.conf
a2ensite wordpress.conf
a2enmod rewrite

# Reiniciar Apache
systemctl restart apache2

# Limpiar archivos temporales
rm -rf latest.tar.gz

echo "Instalación completada. Accede a http://localhost/wordpress para configurar WordPress."
