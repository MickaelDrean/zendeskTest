#!/bin/bash

set -e

echo "Démarrage des services MySQL et Apache..."
sudo service mysql start
sudo service apache2 start

# Téléchargement de HelpDeskZ si pas déjà présent
if [ ! -d "helpdeskz" ]; then
  echo "Téléchargement de HelpDeskZ..."
  wget -q https://www.helpdeskz.com/download/helpdeskz_latest.zip
  unzip helpdeskz_latest.zip
  rm helpdeskz_latest.zip
fi

# Copier dans le répertoire web
echo "Copie des fichiers dans /var/www/html/helpdeskz..."
sudo rm -rf /var/www/html/helpdeskz
sudo cp -r helpdeskz /var/www/html/helpdeskz
sudo chown -R www-data:www-data /var/www/html/helpdeskz

# Création de la base de données et utilisateur MySQL
echo "Configuration MySQL..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS helpdeskz_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'helpdeskz_user'@'localhost' IDENTIFIED BY 'motdepassefort';"
sudo mysql -e "GRANT ALL PRIVILEGES ON helpdeskz_db.* TO 'helpdeskz_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Modification automatique de la config HelpDeskZ
CONFIG_FILE="/var/www/html/helpdeskz/includes/config.php"

if [ -f "$CONFIG_FILE" ]; then
  echo "Configuration de la connexion à la base de données dans config.php..."
  sudo sed -i "s/define('DB_NAME', '.*');/define('DB_NAME', 'helpdeskz_db');/" $CONFIG_FILE
  sudo sed -i "s/define('DB_USER', '.*');/define('DB_USER', 'helpdeskz_user');/" $CONFIG_FILE
  sudo sed -i "s/define('DB_PASSWORD', '.*');/define('DB_PASSWORD', 'motdepassefort');/" $CONFIG_FILE
  sudo sed -i "s/define('DB_HOST', '.*');/define('DB_HOST', 'localhost');/" $CONFIG_FILE
else
  echo "Attention : fichier config.php introuvable, vérifie la structure de HelpDeskZ."
fi

# Redémarrage d'Apache
sudo service apache2 restart

echo "Setup terminé. Accède à http://localhost:8080/helpdeskz"
