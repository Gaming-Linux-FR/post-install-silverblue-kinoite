## Configuration de Fedora Silverblue ou Kinoite

## Table des matières

<div align="center">

&ensp;[<kbd> <br> Flatpak ou RPM ? <br> </kbd>](#flatpak-ou-rpm-)&ensp;
&ensp;[<kbd> <br> Pilotes Nvidia <br> </kbd>](#pilotes-nvidia)&ensp;
&ensp;[<kbd> <br> Suppression de l'Option `nomodeset` <br> </kbd>](#suppression-de-loption-nomodeset)&ensp;
&ensp;[<kbd> <br> AMD & Intel <br> </kbd>](#amd--intel)&ensp;
&ensp;[<kbd> <br> Installation d'Applications avec rpm-ostree <br> </kbd>](#installation-dapplications-avec-rpm-ostree)&ensp;
&ensp;[<kbd> <br> Installation d'Applications avec flatpak <br> </kbd>](#installation-dapplications-avec-flatpak)&ensp;
&ensp;[<kbd> <br> Ajout de Dépôts RPM Fusion <br> </kbd>](#ajout-de-dépôts-rpm-fusion)&ensp;
&ensp;[<kbd> <br> Firefox avec CODEC <br> </kbd>](#firefox-avec-codec)&ensp;
&ensp;[<kbd> <br> Mise à jour du Système (Rebase) <br> </kbd>](#mise-à-jour-du-système-rebase)&ensp;
&ensp;[<kbd> <br> Restauration du Système (Rollback) <br> </kbd>](#restauration-du-système-rollback)&ensp;
&ensp;[<kbd> <br> Installation de xpadneo <br> </kbd>](#installation-de-xpadneo)&ensp;

<br><br><br><br></div>

Votre document est bien structuré et la table des matières fournie devrait offrir une navigation fluide et intuitive pour les lecteurs. Assurez-vous que les sections de votre document sont clairement définies et correspondent aux liens fournis dans la table des matières pour la meilleure expérience utilisateur.

Assurez-vous que chaque élément de cette table des matières correspond à un titre dans votre document, avec un identifiant approprié pour permettre la navigation. Par exemple, pour le titre "Flatpak ou RPM ?", l'identifiant serait `#flatpak-ou-rpm-`. Adapter les identifiants selon les titres exacts de votre document pour assurer une navigation fluide.

### Flatpak ou RPM ? 

Le choix entre l'utilisation de Flatpak et les paquets RPM sur Fedora Silverblue/Kinoite est largement une question de préférence personnelle, chaque méthode ayant ses avantages et ses inconvénients. Les paquets RPM, intégrés au système via `rpm-ostree`, peuvent parfois être moins à jour que leurs homologues disponibles dans les dépôts Flatpak. De plus, leur application nécessite un redémarrage du système pour prendre effet, en raison de la nature immuable de Silverblue/Kinoite. D'un autre côté, bien que Flatpak offre des versions plus récentes des applications et une isolation du dydtème qui peut améliorer la stabilité et la compatibilité, il peuvent nécessiter une gestion manuelle des permissions, comme l'accès à un second disque dur (voir exemple avec steam plus bas). Ce choix dépend donc de vos connaissances et habitudes. 

### Pilotes Nvidia

Important : Désactivez le Secure Boot dans le BIOS/UEFI de l'ordinateur pour permettre l'installation des modules DKMS, essentiels pour les pilotes Nvidia mais aussi par exemple pour Xpadneo bien utile pour les manettes Xbox recentes.

```bash
sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia
sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
```

### Suppression de l'Option `nomodeset`

Si vous suspectez que l'option `nomodeset` est activée (ce qui peut entraver le bon fonctionnement des pilotes graphiques Nvidia), vous pouvez la supprimer en exécutant :

```bash
sudo rpm-ostree kargs --delete=nomodeset
```

Si le système retourne le message suivant :

```
error: No key 'nomodeset' found
```

Cela signifie que l'option `nomodeset` n'était pas activée, ce qui est l'état souhaité pour garantir une compatibilité optimale avec les pilotes Nvidia.

### AMD & Intel
Pris en charge nativement.

### Installation d'Applications avec rpm-ostree
```bash
sudo rpm-ostree install fastfetch lutris goverlay wine steam-devices
```

### Installation d'Applications avec flatpak

Vous pouvez simplement passer par Gnome logiciel sur Silverblue ou Discover sur Kinoite sachez ce pendant que par exemple pour que un flatpak ait accès à un second stockage c'est ce genre de commandes :

```bash
flatpak override --user --filesystem=/chemin/vers/SSD com.valvesoftware.Steam
```

### Ajout de Dépôts RPM Fusion
```bash
sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
### Firefox avec CODEC

Pour assurer la prise en charge complète des codecs dans Firefox sur Fedora Silverblue, permettant ainsi la lecture de toutes les vidéos, suivez ces étapes pour remplacer la version par défaut de Firefox par celle disponible via Flatpak de Flathub :

1. **Supprimez Firefox installé par défaut** :
    - Exécutez la commande suivante pour retirer Firefox et ses paquets de langues associés du système :
        ```bash
        rpm-ostree override remove firefox firefox-langpacks
        ```

2. **Installez Firefox via Flatpak** :
    - Ouvrez **Gnome Software** (Logiciels GNOME).
    - Recherchez **Firefox**.
    - Assurez-vous de sélectionner la version provenant de **Flathub** et non celle du dépôt Fedora.
    - Cliquez sur **Installer** pour procéder avec l'installation.

Cette méthode vous permet d'accéder à une version de Firefox intégrant nativement le support étendu des codecs, indispensable pour une expérience de navigation optimale, notamment pour la lecture vidéo. Opter pour la version Flatpak de Flathub garantit également que vous bénéficiez des mises à jour directes de l'application, indépendamment des cycles de mise à jour du système d'exploitation.

### Mise à jour du Système (Rebase)
```bash
rpm-ostree rebase fedora:fedora/40/x86_64/silverblue
```
Autres exemples :
- Pour passer à Fedora 41 : `rpm-ostree rebase fedora:fedora/41/x86_64/silverblue`
- Pour revenir à Fedora 39 : `rpm-ostree rebase fedora:fedora/39/x86_64/silverblue`

### Restauration du Système (Rollback)
- **Temporaire** : Redémarrez et sélectionnez la version précédente dans le menu de démarrage.
- **Permanent** : Utilisez `sudo rpm-ostree rollback` sur e système que vous voulez garder et mettre en priorité au boot.

Pour intégrer l'installation de `xpadneo`, un pilote avancé pour les manettes Xbox sous Linux, adapté aux spécificités de Fedora Silverblue ou toute autre version immuable de Fedora, voici comment procéder :

### Installation de [xpadneo](https://github.com/atar-axis/xpadneo)

Ces étapes vous permettront d'installer le pilote `xpadneo` sur Fedora Silverblue, offrant une meilleure expérience d'utilisation des manettes Xbox récentes.

1. **Ajout du dépôt COPR** :
    - Exécutez la commande suivante pour ajouter le dépôt COPR de `xpadneo` :
        ```bash
        sudo wget -O /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:shdwchn10:xpadneo.repo https://copr.fedorainfracloud.org/coprs/shdwchn10/xpadneo/repo/fedora-$(rpm -E %fedora)/shdwchn10-xpadneo-fedora-$(rpm -E %fedora).repo
        ```

2. **Installation de xpadneo** :
    - Utilisez ensuite cette commande pour installer le pilote `xpadneo` :
        ```bash
        rpm-ostree install xpadneo
        ```
