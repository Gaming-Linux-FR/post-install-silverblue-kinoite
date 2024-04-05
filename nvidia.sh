#!/bin/bash

# Définition d'un gestionnaire d'erreur
function errorHandler {
    echo -e "${RED}Une erreur est survenue. Veuillez redémarrer votre système et réessayer d'exécuter le script. Ouvrir une issue sur le GitHub si l'erreur persiste.${RESET}" 1>&2
    exit 1
}

# Vérification de la connectivité Internet
function checkInternet {
    echo "${BLUE}Vérification de la connectivité Internet...${RESET}"
    if ! ping -c 1 google.com &> /dev/null; then
        echo "${RED}Une connexion Internet est requise pour exécuter ce script. Vérifiez votre connexion et réessayez.${RESET}"
        exit 1
    else
        echo "${GREEN}Connectivité Internet confirmée.${RESET}"
    fi
}

# Configuration du script pour appeler errorHandler en cas d'erreur
trap errorHandler ERR

set -e # Arrête le script en cas d'erreur

# Définition des couleurs
RESET=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PURPLE=$(tput setaf 5)

# Vérification de l'exécution du script en tant que root
if [ "$(id -u)" != "0" ]; then
   echo "${RED}Ce script doit être exécuté en tant que root. Veuillez lancer avec sudo ou en tant que root.${RESET}" 1>&2
   exit 1
fi

checkInternet # Appel de la fonction de vérification de la connectivité Internet

# Définition des URLs RPM Fusion
RPMFUSION_FREE="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
RPMFUSION_NONFREE="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

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

# Configuration et nettoyage des arguments du noyau pour Nvidia, si nécessaire
KARGS_NEEDED="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"
KARGS_CURRENT=$(rpm-ostree kargs)

# Initialiser une chaîne pour les modifications d'arguments du noyau
KARGS_MODS=""

# Vérifier chaque argument nécessaire et le planifier pour ajout si absent
for KARG in $KARGS_NEEDED; do
    if [[ ! $KARGS_CURRENT =~ $KARG ]]; then
        echo "${YELLOW}Planification de l'ajout de l'argument du noyau $KARG...${RESET}"
        KARGS_MODS+=" --append=$KARG"
    else
        echo "${GREEN}L'argument du noyau $KARG est déjà défini.${RESET}"
    fi
done

# Planifier la suppression de l'argument `nomodeset` si présent
if [[ $KARGS_CURRENT =~ nomodeset ]]; then
    echo "${YELLOW}Planification de la suppression de l'argument du noyau 'nomodeset'...${RESET}"
    KARGS_MODS+=" --delete=nomodeset"
else
    echo "${GREEN}L'argument du noyau 'nomodeset' n'est pas défini. Aucune action requise.${RESET}"
fi

# Appliquer toutes les modifications d'arguments du noyau en une seule commande, si nécessaire
if [ -n "$KARGS_MODS" ]; then
    echo "${YELLOW}Application des modifications d'arguments du noyau...${RESET}"
    rpm-ostree kargs $KARGS_MODS
else
    echo "${GREEN}Aucune modification d'argument du noyau nécessaire. Configuration actuelle déjà optimale.${RESET}"
fi


# Vérification de la présence des dépôts RPM Fusion et mise à jour si nécessaire
echo "${BLUE}Vérification et mise à jour des dépôts RPM Fusion si nécessaire...${RESET}"
RPM_OSTREE_STATUS=$(rpm-ostree status)

# Vérification si les dépôts RPM Fusion sont déjà configurés
DEPOTS_FREE_INSTALLED=$(echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-free-release' && echo "yes" || echo "no")
DEPOTS_NONFREE_INSTALLED=$(echo "$RPM_OSTREE_STATUS" | grep -q 'rpmfusion-nonfree-release' && echo "yes" || echo "no")

# Ajout des dépôts si non présents, et mise à jour pour utiliser les versions non versionnées
if [ "$DEPOTS_FREE_INSTALLED" = "no" ] || [ "$DEPOTS_NONFREE_INSTALLED" = "no" ]; then
    echo "${YELLOW}Installation et mise à jour des dépôts RPM Fusion...${RESET}"
    sudo rpm-ostree install $RPMFUSION_FREE $RPMFUSION_NONFREE --apply-live
    
    # Remplacer les dépôts versionnés par les versions actuelles
    sudo rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release
else
    echo "${GREEN}Les dépôts RPM Fusion sont déjà configurés. Vérification de la nécessité de mise à jour...${RESET}"
    # Remplacer les dépôts versionnés par les versions actuelles sans les installer à nouveau si déjà présents
    sudo rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release
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
