#!/bin/bash

set -e # Arrête le script en cas d'erreur

# Vérification de l'exécution du script en tant que root
if [ "$(id -u)" != "0" ]; then
   echo "${RED}Ce script doit être exécuté en tant que root. Veuillez lancer avec sudo ou en tant que root.${RESET}" 1>&2
   exit 1
fi

# Définition des couleurs
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)

# Fonction d'en-tête pour l'affichage initial
function header() {
    clear
    cat <<-EOF
-----------------------------------------------------------------------------------------------------------

       ${PURPLE}%%%%%%%%%%${RESET}  ${GREEN}*********${RESET}            
       ${PURPLE}%%%${RESET}                 ${GREEN}******${RESET}       
       ${PURPLE}%%%${RESET}                     ${GREEN}***${RESET}      Script d'installation des drivers Nvidia pour Fedora Silverblue/Kinoite
       ${PURPLE}%%%${RESET}                     ${GREEN}***${RESET}      
       ${PURPLE}%%%${RESET}                     ${GREEN}***${RESET}      GitHub : https://github.com/Gaming-Linux-FR
       ${PURPLE}%%%${RESET}                     ${GREEN}***${RESET}      
       ${PURPLE}%%%${RESET}                     ${GREEN}***${RESET} 
        ${PURPLE}%%%%%%${RESET}                 ${GREEN}***${RESET} 
             ${PURPLE}%%%%%%%%${RESET}  ${GREEN}***********${RESET}     

-----------------------------------------------------------------------------------------------------------
EOF

    sleep 1
    echo "${RED}Ce script va apporter des modifications à votre système.${RESET}"; echo
    echo "Certaines étapes peuvent prendre plus de temps, en fonction de votre connexion Internet et de votre CPU."; echo
    echo "Appuyez sur ${GREEN}Entrée${RESET} pour continuer, ou ${RED}Ctrl+C${RESET} pour annuler."; echo

    read -rp ""
}

# Affichage de l'en-tête
header

# Message de début du script
echo "${BLUE}Début du script d'installation des drivers Nvidia sur Fedora Silverblue${RESET}"

# Chargement des modules Nvidia dans l'initramfs
if [ ! -f "/etc/dracut.conf.d/nvidia.conf" ]; then
    echo "${YELLOW}Création du fichier de configuration pour Nvidia...${RESET}"
    echo "force_drivers+=\" nvidia nvidia_modeset nvidia_uvm nvidia_drm \"" | sudo tee /etc/dracut.conf.d/nvidia.conf > /dev/null
else
    echo "${GREEN}Le fichier de configuration pour Nvidia existe déjà.${RESET}"
fi

# Configuration des arguments du noyau pour Nvidia, si nécessaire
KARGS_NEEDED="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 nvidia-drm.fbdev=1"
KARGS_CURRENT=$(rpm-ostree kargs)

for KARG in $KARGS_NEEDED; do
    if [[ ! $KARGS_CURRENT =~ $KARG ]]; then
        echo "${YELLOW}Ajout de l'argument du noyau $KARG...${RESET}"
        rpm-ostree kargs --append=$KARG --quiet
    else
        echo "${GREEN}L'argument du noyau $KARG est déjà défini.${RESET}"
    fi
done

# Vérification et suppression de l'argument `nomodeset`, si présent
if [[ $KARGS_CURRENT =~ nomodeset ]]; then
    echo "${YELLOW}Suppression de l'argument du noyau 'nomodeset'...${RESET}"
    rpm-ostree kargs --delete=nomodeset --quiet
else
    echo "${GREEN}L'argument du noyau 'nomodeset' n'est pas défini. Aucune action requise.${RESET}"
fi

# Vérification de la présence des dépôts RPM Fusion
echo "${BLUE}Vérification des dépôts RPM Fusion...${RESET}"
RPM_OSTREE_STATUS=$(rpm-ostree status)
if ! echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-free-release'; then
    echo "${YELLOW}Ajout du dépôt

 RPM Fusion Free...${RESET}"
    rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm --quiet
else
    echo "${GREEN}Le dépôt RPM Fusion Free est déjà configuré.${RESET}"
fi

if ! echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-nonfree-release'; then
    echo "${YELLOW}Ajout du dépôt RPM Fusion Non-Free...${RESET}"
    rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm --quiet
else
    echo "${GREEN}Le dépôt RPM Fusion Non-Free est déjà configuré.${RESET}"
fi

# Vérification et installation des pilotes Nvidia si nécessaire
echo "${BLUE}Vérification de l'installation des pilotes Nvidia...${RESET}"
if ! echo "$RPM_OSTREE_STATUS" | grep -q 'akmod-nvidia'; then
    echo "${YELLOW}Installation du driver Nvidia...${RESET}"
    rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda --quiet
else
    echo "${GREEN}Les pilotes Nvidia sont déjà installés.${RESET}"
fi

# Conclusion
echo "${GREEN}Installation des drivers Nvidia et configuration terminées, redémarrez votre système pour appliquer les changements.${RESET}"