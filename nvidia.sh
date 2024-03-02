#!/bin/bash

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
       ${PURPLE}%%%${RESET}                     ${GREEN}***${RESET}      GitHub : https://github.com/Cardiacman13/Architect
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

    read -rp "" choice
    [[ -n $choice ]] && exit 0
}

#fonction header
header

# Vérification de l'exécution du script en tant que root
if [ "$(id -u)" != "0" ]; then
   echo "Ce script doit être exécuté en tant que root. Veuillez lancer avec sudo ou en tant que root." 1>&2
   exit 1
fi

# Obtention du répertoire du script
SCRIPT_DIR=$(dirname "$0")

# Définition du chemin du fichier de log dans le même répertoire que le script
LOGFILE="$SCRIPT_DIR/post_install_nvidia.log"
echo "Début du script d'installation des drivers Nvidia sur Fedora Silverblue" | tee $LOGFILE

# Configuration des arguments du noyau pour Nvidia, si nécessaire
KARGS_NEEDED="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"
KARGS_CURRENT=$(rpm-ostree kargs)

for KARG in $KARGS_NEEDED; do
    if [[ ! $KARGS_CURRENT =~ $KARG ]]; then
        echo "Ajout de l'argument du noyau $KARG..." | tee -a $LOGFILE
        sudo rpm-ostree kargs --append=$KARG
    else
        echo "L'argument du noyau $KARG est déjà défini." | tee -a $LOGFILE
    fi
done

echo "Configuration des arguments du noyau terminée." | tee -a $LOGFILE

# Vérification et suppression de l'argument `nomodeset`, si présent
if [[ $KARGS_CURRENT =~ nomodeset ]]; then
    echo "Suppression de l'argument du noyau 'nomodeset'..." | tee -a $LOGFILE
    sudo rpm-ostree kargs --delete=nomodeset
else
    echo "L'argument du noyau 'nomodeset' n'est pas défini. Aucune action requise." | tee -a $LOGFILE
fi

echo "Vérification et configuration des arguments du noyau terminées." | tee -a $LOGFILE

# Vérification de la présence des dépôts RPM Fusion
echo "Vérification des dépôts RPM Fusion..." | tee -a $LOGFILE
RPM_OSTREE_STATUS=$(rpm-ostree status)
if ! echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-free-release'; then
    echo "Ajout du dépôt RPM Fusion Free..." | tee -a $LOGFILE
    sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm | tee -a $LOGFILE
else
    echo "Le dépôt RPM Fusion Free est déjà configuré." | tee -a $LOGFILE
fi

if ! echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-nonfree-release'; then
    echo "Ajout du dépôt RPM Fusion Non-Free..." | tee -a $LOGFILE
    sudo rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm | tee -a $LOGFILE
else
    echo "Le dépôt RPM Fusion Non-Free est déjà configuré." | tee -a $LOGFILE
fi

# Vérification et installation des pilotes Nvidia si nécessaire
echo "Vérification de l'installation des pilotes Nvidia..." | tee -a $LOGFILE
if ! echo "$RPM_OSTREE_STATUS" | grep -q 'akmod-nvidia'; then
    echo "Installation du driver Nvidia..." | tee -a $LOGFILE
    sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda | tee -a $LOGFILE
else
    echo "Les pilotes Nvidia sont déjà installés." | tee -a $LOGFILE
fi

# Autres configurations et vérifications...

echo "Installation des drivers Nvidia et configuration terminées, redémarrez." | tee -a $LOGFILE

