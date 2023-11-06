#installation de LAMP et de prestashop

#déclaration de mes variables pour l'installation de prestashop
PS_VERSION="8.1.1"  # Version de PrestaShop à installer
PS_DOWNLOAD_URL="https://www.prestashop.com/download/old/prestashop_$PS_VERSION.zip"
PS_INSTALL_DIR="/var/www/html/prestashop"



#création d'un profil de connexion pour désactiver root

if ['$(whoiam)' !='root']; then 
    SUDO=sudo
fi


#mise à jour de ma machine et des packets
${SUDO} apt update
${SUDO} apt upgrade -y





#installation de php 8.1 à partir d'un repo autre que celui de base
${SUDO} apt-get update
${SUDO} apt-get -y install lsb-release ca-certificates curl
${SUDO} curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
${SUDO} sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
${SUDO} apt-get update


${SUDO} apt update
${SUDO} apt list --upgradable
${SUDO} apt upgrade 
${SUDO} apt install php8.1
${SUDO} a2dismod php8.2
${SUDO} a2enmod php8.1
${SUDO} systemctl restart apache2


#installation de LAM et de unzip pour dézipper l'archive prestashop
${SUDO} apt install -y apache2 mariadb-server libapache2-mod-php php8.1-mysqli unzip
${SUDO} systemctl restart apache2




#creation d'un nouvel user pour la connexion ssh
#  NEW_USER = anthony
# ${SUDO} useradd ${NEW_USER}

#création d'un vhote pour le site
${SUDO} mkdir /var/www/html/chat

#ajout d'un vhost pour le serveur node sur apache2
${SUDO} touch /etc/apache2/sites-available/chat.conf
${SUDO} echo "<VirtualHost *:80>
    ServerName chatbot.anthony-kalbe.fr
    ServerAlias www.chatbot.athony-kalbe.com
    DocumentRoot /var/www/html/chat
    <Directory /var/www/html/chat>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>" >> /etc/apache2/sites-available/chat.conf

#installation de nodejs
${SUDO} apt install nodejs -y
#installation de npm
${SUDO} apt install npm -y

# #recup le git
# ${SUDO}  apt install git -y
# ${SUDO} git clone **le lien** /var/www/html/chat
# cd /var/www/html/chat
# ${SUDO} npm install








#lancement de mysql_secure_installation
mysql_secure_installation

${SUDO} apt install  phpmyadmin

${SUDO} mysql 
#création de la base de données
mysql <<<EOF
CREATE USER 'database_admin'@'localhost' IDENTIFIED BY '#P_Wd/BdD1'; 
GRANT ALL PRIVILEGES ON * . * TO 'toto'@'localhost';
EOF

quit


############## ajout du certificat ssl ################

#activation du module ssl d'apache2
${SUDO} a2enmod ssl 
${SUDO} a2enmod rewrite 
${SUDO} a2enmod proxy proxy_ajp proxy_http rewrite deflate headers proxy_balancer proxy_connect proxy_html
#redémarrage du serveur apache pour que les modifications soient prise en compte
${SUDO} systemctl reload apache2

#ajout du ssl sur le site default
${SUDO} a2ensite default-ssl


#redémarrage du serveur apache pour que les modifications soient prise en compte
${SUDO} systemctl reload apache2


#installation de let's encrypt sur le serveur
${SUDO} apt install python3-certbot-apache -y
${SUDO} certbot certonly --standalone --agree-tos --preferred-challenges http -d ip87-106-123-61.pbiaas.com








#ajout des droits 
${SUDO} chown -R www-data:www-data /var/www/html
${SUDO} chmod -R g+w /var/www/html


a2enmod auth_basic


#installation des prestashop
${SUDO} apt install php8.2-curl php8.2-dom php8.2-fileinfo php8.2-gd php8.2-intl php8.2-mbstring php8.2-zip php8.2-iconv



cd /var/www/html
${SUDO} mkdir presta
cd presta
wget https://github.com/PrestaShop/PrestaShop/releases/download/8.1.1/prestashop_8.1.1.zip
unzip prestashop_8.1.1.zip
${SUDO} rm -R prestashop_8.1.1.zip
${SUDO} chmod -R g+w /var/www/html/presta

echo 'il ne vous reste plus qu'à importer la base de données et à finir l'installation de prestashop'
     














# #creation du user de FTP
# useradd -M -g www-data -s /usr/sbin/nologin tata anthony_upload
# echo 'merci de mettre le mot de passe pour l'utilisateur lié au ftp
# passwd tata



# # Variables pour la connexion SSH
# SSH_USER="Upload_files"
# SSH_PASSWORD="Upload_files"

# # Variables pour l'utilisateur FTP
# FTP_USER="FTP_user"
# FTP_PASSWORD="FTP_password"

# Mise à jour du système
sudo apt update
sudo apt upgrade -y

# Installation de LAMP
# sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Redémarrage des services
sudo systemctl restart apache2
sudo systemctl restart mysql

# Téléchargement et installation de PrestaShop
sudo apt install -y unzip
sudo wget "$PS_DOWNLOAD_URL" -O /tmp/prestashop.zip
sudo unzip /tmp/prestashop.zip -d /tmp
sudo mv /tmp/prestashop/* "$PS_INSTALL_DIR"
sudo rm -rf /tmp/prestashop /tmp/prestashop.zip

# Configuration de la base de données MySQL
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE prestashop;
CREATE USER 'prestashop'@'localhost' IDENTIFIED BY 'mot_de_passe_mysql';
GRANT ALL PRIVILEGES ON prestashop.* TO 'prestashop'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Configuration du site web PrestaShop
sudo chown -R www-data:www-data "$PS_INSTALL_DIR"
sudo chmod -R 755 "$PS_INSTALL_DIR"
sudo chmod -R 777 "$PS_INSTALL_DIR"/app/config/ "$PS_INSTALL_DIR"/var/ "$PS_INSTALL_DIR"/img/ "$PS_INSTALL_DIR"/mails/ "$PS_INSTALL_DIR"/modules/ "$PS_INSTALL_DIR"/themes/ "$PS_INSTALL_DIR"/translations/ "$PS_INSTALL_DIR"/upload/

# Configuration de la connexion SSH
sudo useradd -m -p "$(openssl passwd -1 "$SSH_PASSWORD")" -s /bin/bash "$SSH_USER"

# Installation et configuration de vsftpd (serveur FTP)
sudo apt install -y vsftpd
sudo systemctl enable vsftpd
sudo systemctl start vsftpd

# Création d'un utilisateur FTP
sudo useradd -m -p "$(openssl passwd -1 "$FTP_PASSWORD")" -s /bin/bash "$FTP_USER"

# Génération d'un certificat SSL auto-signé pour Apache
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

# Configuration d'Apache pour utiliser le certificat SSL
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak
sudo sed -i 's/\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/\/etc\/ssl/certs/apache-selfsigned.crt/g' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i 's/\/etc\/ssl\/private\/ssl-cert-snakeoil.key/\/etc\/ssl/private/apache-selfsigned.key/g' /etc/apache2/sites-available/default-ssl.conf
sudo a2enmod ssl
sudo a2ensite default-ssl
sudo systemctl restart apache2

# Redémarrage d'Apache
sudo systemctl restart apache2
