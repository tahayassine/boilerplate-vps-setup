#!/bin/bash

# Demander l'adresse e-mail pour GitHub
read -p "Entrez votre adresse e-mail pour GitHub : " GITHUB_EMAIL

# Demander le mot de passe pour GitHub
read -s -p "Entrez votre mot de passe pour GitHub (ne sera pas affiché) : " GITHUB_PASSWORD
echo

# Mettre à jour la liste des paquets
sudo apt-get update

# Installer les dépendances nécessaires
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    openssh-server

# Ajouter la clé GPG officielle de Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Ajouter le repository Docker aux sources APT
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Mettre à jour la liste des paquets à nouveau pour inclure le repository Docker
sudo apt-get update

# Installer Docker CE (Community Edition)
sudo apt-get install -y docker-ce

# Installer Git
sudo apt-get install -y git

# Vérifier l'installation de Docker
sudo docker --version

# Vérifier l'installation de Git
git --version

# Installer Cockpit
sudo apt-get install -y cockpit

# Démarrer et activer Cockpit
sudo systemctl enable --now cockpit.socket
sudo systemctl start cockpit

# Configurer l'accès SSH pour GitHub
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "Clé SSH non trouvée, génération d'une nouvelle clé SSH..."
    ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL" -N "" -f "$HOME/.ssh/id_rsa"
fi

# Ajouter la clé SSH au SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Afficher la clé publique
echo "Clé SSH publique :"
cat ~/.ssh/id_rsa.pub

echo "Copiez la clé ci-dessus et ajoutez-la à votre compte GitHub sous Settings -> SSH and GPG keys."

# Configurer l'accès SSH au serveur
sudo systemctl enable ssh
sudo systemctl start ssh

# Afficher l'adresse IP du serveur
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "L'accès SSH au serveur est activé. Utilisez l'adresse IP suivante pour vous connecter : $IP_ADDRESS"

# Configurer Git avec l'e-mail et le mot de passe
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_EMAIL"

echo "Configuration de Git avec l'adresse e-mail $GITHUB_EMAIL."

# Afficher l'URL pour accéder à Cockpit
echo "Cockpit est installé et en cours d'exécution. Accédez à Cockpit via https://$IP_ADDRESS:9090 en utilisant vos identifiants du serveur."

echo "Installation de Git, Docker, Cockpit, et configuration des accès SSH terminées avec succès !"
