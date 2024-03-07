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

# Définition du chemin du fichier de log
SCRIPT_DIR=$(dirname "$0")
LOGFILE="$SCRIPT_DIR/post_install_nvidia.log"

# Message de début du script
echo "${BLUE}Début du script d'installation des drivers Nvidia sur Fedora Silverblue${RESET}"

# Chargement des modules Nvidia dans l'initramfs
echo "${BLUE}Configuration du chargement précoce des modules Nvidia...${RESET}"
echo "force_drivers+=\" nvidia nvidia_modeset nvidia_uvm nvidia_drm \"" | sudo tee /etc/dracut.conf.d/nvidia.conf > /dev/null

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
    echo "${YELLOW}Suppression de l'argument du noyau 'nomodeset'...${RESET}" | tee -a $LOGFILE
    rpm-ostree kargs --delete=nomodeset --quiet
else
    echo "${GREEN}L'argument du noyau 'nomodeset' n'est pas défini. Aucune action requise.${RESET}" | tee -a $LOGFILE
fi

# Vérification de la présence des dépôts RPM Fusion
echo "${BLUE}Vérification des dépôts RPM Fusion...${RESET}" | tee -a $LOGFILE
RPM_OSTREE_STATUS=$(rpm-ostree status)
if ! echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-free-release'; then
    echo "${YELLOW}Ajout du dépôt

 RPM Fusion Free...${RESET}" | tee -a $LOGFILE
    rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm --quiet | tee -a $LOGFILE
else
    echo "${GREEN}Le dépôt RPM Fusion Free est déjà configuré.${RESET}" | tee -a $LOGFILE
fi

if ! echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-nonfree-release'; then
    echo "${YELLOW}Ajout du dépôt RPM Fusion Non-Free...${RESET}" | tee -a $LOGFILE
    rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm --quiet | tee -a $LOGFILE
else
    echo "${GREEN}Le dépôt RPM Fusion Non-Free est déjà configuré.${RESET}" | tee -a $LOGFILE
fi

# Vérification et installation des pilotes Nvidia si nécessaire
echo "${BLUE}Vérification de l'installation des pilotes Nvidia...${RESET}" | tee -a $LOGFILE
if ! echo "$RPM_OSTREE_STATUS" | grep -q 'akmod-nvidia'; then
    echo "${YELLOW}Installation du driver Nvidia...${RESET}" | tee -a $LOGFILE
    rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda --quiet | tee -a $LOGFILE
else
    echo "${GREEN}Les pilotes Nvidia sont déjà installés.${RESET}" | tee -a $LOGFILE
fi

# Conclusion
echo "${GREEN}Installation des drivers Nvidia et configuration terminées, redémarrez votre système pour appliquer les changements.${RESET}" | tee -a $LOGFILE