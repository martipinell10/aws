#!/bin/bash

# Verifica si som root o no
if [ "$EUID" -ne 0 ]; then
    echo "ERROR, l'script no s'executa com a usuari root."
    exit
fi


# Actualitzar respositoris i instal·lar Apache2.
apt-get update
apt-get install -y apache2


# Instal·lar PHP i altres mòduls necesaris per a WordPress.
apt-get install -y php libapache2-mod-php php-mysql


# Descarregar i instal·lar MySQL i configurar credencials de root.
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password password system"
debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password_again password system"
apt-get install -y mariadb-server

# Crear Base de dades i usuari per a WordPress.
mysql -u root -p"your_root_password" -e "CREATE DATABASE wordpress;"
mysql -u root -p"your_root_password" -e "CREATE USER 'system'@'localhost' IDENTIFIED BY 'system';"
mysql -u root -p"your_root_password" -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'system'@'localhost';"
mysql -u root -p"your_root_password" -e "FLUSH PRIVILEGES;"


# Descarregar i instal·lar WordPress.
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress


# Configurar Apache2 per a WordPress.
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
echo "ServerName localhost" >> /etc/apache2/sites-available/wordpress.conf
echo "DocumentRoot /var/www/html/wordpress" >> /etc/apache2/sites-available/wordpress.conf
a2ensite wordpress.conf
a2enmod rewrite


# Reiniciar servei Apache2.
systemctl restart apache2


# Natejar fitxers temporals.
rm -rf latest.tar.gz


# Comentari final.
echo "Instal·lació completada. Siusplau, accedeixi a la pàgina de WordPress per configurar-lo.
