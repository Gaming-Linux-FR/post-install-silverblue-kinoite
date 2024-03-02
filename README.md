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

### Flatpak ou RPM ? 

Le choix entre l'utilisation de Flatpak et les paquets RPM sur Fedora Silverblue/Kinoite est largement une question de préférence personnelle, chaque méthode ayant ses avantages et ses inconvénients. Les paquets RPM, intégrés au système via `rpm-ostree`, peuvent parfois être moins à jour que leurs homologues disponibles dans les dépôts Flatpak. De plus, leur application nécessite un redémarrage du système pour prendre effet, en raison de la nature immuable de Silverblue/Kinoite. D'un autre côté, bien que Flatpak offre des versions plus récentes des applications et une isolation du sydtème qui peut améliorer la stabilité et la compatibilité, il peuvent nécessiter une gestion manuelle des permissions, comme l'accès à un second disque dur (voir exemple avec steam plus bas). Ce choix dépend donc de vos connaissances et habitudes. 

### Pilotes Nvidia
> [!IMPORTANT]
>  Quel que soit le DE rester sur X11 au moins jusqu'au merge de ce patch : [explicit-sync](https://gitlab.freedesktop.org/xorg/xserver/-/merge_requests/967),
>  Désactivez le Secure Boot dans le BIOS/UEFI de l'ordinateur pour permettre l'installation des modules [DKMS](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support_(Fran%C3%A7ais)), essentiels pour les pilotes Nvidia mais aussi par exemple pour Xpadneo bien utile pour les manettes Xbox recentes.

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
sudo rpm-ostree install fastfetch lutris goverlay wine
```

### Installation d'Applications avec flatpak

Vous pouvez simplement passer par Gnome logiciel sur Silverblue ou Discover sur Kinoite sachez ce pendant que par exemple pour que un flatpak ait accès à un second stockage c'est ce genre de commandes :

```bash
flatpak override --user --filesystem=/chemin/vers/SSD com.valvesoftware.Steam
```

Pour Steam flatpak si votre manette ne fonctionne pas vous pouvez tenter : 

```bash
sudo rpm-ostree install steam-devices
```

### Ajout de Dépôts RPM Fusion
```bash
sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

### Firefox avec CODECs non libres.
Pour assurer la prise en charge complète des codecs dans Firefox sur Fedora Silverblue/Kinoite, permettant ainsi la lecture de toutes les vidéos, suivez ces étapes pour remplacer la version par défaut de Firefox par celle disponible via Flatpak de Flathub :

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
- Pour passer à Silverblue 40 : `rpm-ostree rebase fedora:fedora/40/x86_64/silverblue`
- Pour revenir à Silverblue 39 : `rpm-ostree rebase fedora:fedora/39/x86_64/silverblue`

Pour Kinoite : 

- Pour passer à Kinoite 40 : `rpm-ostree rebase fedora:fedora/40/x86_64/kinoite`
- Pour revenir à Kinoite 39 : `rpm-ostree rebase fedora:fedora/39/x86_64/kinoite`

Pour les versions de développement remplacer le numéro de version par rawhide :

exemples :

- Pour passer à Kinoite Rawhide    : `rpm-ostree rebase fedora:fedora/rawhide/x86_64/kinoite`
- Pour passer à Silverblue Rawhide : `rpm-ostree rebase fedora:fedora/rawhine/x86_64/silverblue`

On peut passer de Kinoite à Silverblue sans problème, il faut juste reboot après une rebase. Si jamais il y a un problème on peut booter sur l'ancienne entrée et rollback pour la repasser en entée principale.

### Restauration du Système (Rollback)
- **Temporaire** : Redémarrez et sélectionnez la version précédente dans le menu de démarrage.
- **Permanent** : Utilisez `sudo rpm-ostree rollback` sur e système que vous voulez garder et mettre en priorité au boot.

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
Comme pour Nvidia, le sécure boot doit être désactivé dans le bios car c'est [DKMS](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support_(Fran%C3%A7ais))
