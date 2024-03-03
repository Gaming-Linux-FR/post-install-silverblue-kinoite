# Configuration de Fedora Silverblue ou Kinoite

### Table des matières

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
&ensp;[<kbd> <br> Avoir les Gestes au Pavé Tactile sur Gnome X11 <br> </kbd>](#avoir-les-gestes-au-pavé-tactile-sur-gnome-x11)&ensp;
&ensp;[<kbd> <br> Personnalisation de l'Apparence avec Adw-gtk3 <br> </kbd>](#personnalisation-de-lapparence-avec-adw-gtk3)&ensp;
&ensp;[<kbd> <br> Installation et Configuration d'OpenRGB <br> </kbd>](#installation-et-configuration-dopenrgb)&ensp;
&ensp;[<kbd> <br> Steam Flatpak <br> </kbd>](#steam-flatpak)&ensp;
<br></div>

---

## 📦 Flatpak ou RPM ? 

Le choix entre l'utilisation de Flatpak et les paquets RPM sur Fedora Silverblue/Kinoite est largement une question de préférence personnelle, chaque méthode ayant ses avantages et ses inconvénients. Les paquets RPM, intégrés au système via `rpm-ostree`, peuvent parfois être moins à jour que leurs homologues disponibles dans les dépôts Flatpak. De plus, leur application nécessite un redémarrage du système pour prendre effet, en raison de la nature immuable de Silverblue/Kinoite. D'un autre côté, bien que Flatpak offre des versions plus récentes des applications et une isolation du sydtème qui peut améliorer la stabilité et la compatibilité, il peuvent nécessiter une gestion manuelle des permissions, comme l'accès à un second disque dur (voir exemple avec steam plus bas). Ce choix dépend donc de vos connaissances et habitudes.

---

## ➕ Ajout de Dépôts RPM Fusion
Indispensable pour beaucoup de choses dont *Nvidia* :
```bash
sudo rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

---

## 📹 Pilotes Nvidia
> [!IMPORTANT]
>  Quel que soit le DE et la distribution, restez sur *X11* au moins jusqu'à ce que ce patch arrive dans votre distro. : [explicit-sync](https://gitlab.freedesktop.org/xorg/xserver/-/merge_requests/967),
>  Désactivez le Secure Boot dans le BIOS/UEFI de l'ordinateur pour permettre l'installation des modules [DKMS](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support_(Fran%C3%A7ais)), essentiels pour les pilotes Nvidia mais aussi par exemple pour Xpadneo bien utile pour les manettes Xbox recentes.

*Script pour tout automatiser :*
```bash
git clone https://github.com/Gaming-Linux-FR/post-install-silverblue-kinoite.git ~/post-install-silverblue-kinoite && cd ~/post-install-silverblue-kinoite && chmod +x ./nvidia.sh && sudo ./nvidia.sh
```

- Ajout du driver et des options kernel
```bash
sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda
sudo rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
```

- Suppression de l'Option `nomodeset`

Si vous suspectez que l'option `nomodeset` est activée (ce qui peut entraver le bon fonctionnement des pilotes graphiques Nvidia), vous pouvez la supprimer en exécutant :

```bash
sudo rpm-ostree kargs --delete=nomodeset
```

Si le système retourne le message suivant :

```
error: No key 'nomodeset' found
```

Cela signifie que l'option `nomodeset` n'était pas activée, *ce qui est l'état souhaité* pour garantir une compatibilité optimale avec les pilotes Nvidia.

---

## 📹 AMD & Intel
Pris en charge nativement.

---

## 📦 Installation d'Applications avec rpm-ostree
La commande est : ``rpm-ostree install nomdespaquets`` exemple :

```bash
sudo rpm-ostree install fastfetch lutris goverlay wine
```

---

## 📦 Installation d'Applications avec flatpak

Vous pouvez simplement passer par *Gnome logiciel* sur Silverblue ou *Discover* sur Kinoite sachez ce pendant que par exemple pour que un flatpak ait accès à un second stockage c'est ce genre de commandes :

```bash
flatpak override --user --filesystem=/chemin/vers/SSD com.valvesoftware.Steam
```

Pour Steam flatpak si votre manette ne fonctionne pas vous pouvez tenter : 

```bash
sudo rpm-ostree install steam-devices
```

---

## 🎬 Firefox avec CODECs non libres.
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

---

## 🖥️ Mise à jour du Système (Rebase)
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

---

## 🔄 Restauration du Système (Rollback)
- **Temporaire** : Redémarrez et sélectionnez la version précédente dans le menu de démarrage.
- **Permanent** : Utilisez `sudo rpm-ostree rollback` sur e système que vous voulez garder et mettre en priorité au boot.

---

## 🎮 Installation de [xpadneo](https://github.com/atar-axis/xpadneo)

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
Comme pour Nvidia, le *sécure boot doit être désactivé* dans le bios car c'est un [DKMS](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support_(Fran%C3%A7ais))

## Avoir les Gestes au Pavé Tactile sur Gnome X11

Les utilisateurs préférant rester encore un peu sur X11 peuvent améliorer leur expérience en activant les gestes tactiles, ce qui rend la navigation et l'interaction avec le système d'exploitation plus intuitive et fluide.

1. **Installation de Touchégg** :
    - Touchégg est une application qui transforme les gestes sur le pavé tactile en actions. Pour l'installer, utilisez la commande suivante :
        ```bash
        rpm-ostree install touchegg
        ```
    - Après l'installation, redémarrez votre système pour appliquer les changements :
        ```bash
        systemctl reboot
        ```
    - Activez ensuite le service Touchégg pour qu'il démarre automatiquement avec le système :
        ```bash
        systemctl enable --now touchegg
        ```

2. **Installation de l'Extension Gnome X11 Gestures** :
    - Pour une intégration parfaite avec Gnome sous X11, installez l'extension Gnome X11 Gestures. Visitez la page de l'extension sur le site des extensions Gnome à l'adresse suivante et activez-la : [X11 Gestures sur extensions.gnome.org](https://extensions.gnome.org/extension/4033/x11-gestures/).

---

## Personnalisation de l'Apparence avec Adw-gtk3

Pour personnaliser l'apparence de votre Fedora Silverblue ou Kinoite avec le thème Adw-gtk3, suivez ces étapes :

1. **Installation du Gnome Tweak Tool et du Thème Adw-gtk3** :
    ```bash
    sudo rpm-ostree install gnome-tweak-tool adw-gtk3-theme
    ```

2. **Installation des Thèmes Flatpak Adw-gtk3** :
    ```bash
    flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
    ```

3. **Application du Thème** :
    - Ouvrez **Ajustements** (présent dans le dossier **Utilitaires** de GNOME).
    - Naviguez jusqu'à l'onglet **Apparence**.
    - Sélectionnez **Adw-gtk3** dans la section **Anciennes applications** pour appliquer le thème.

Ces étapes vous permettront de bénéficier d'une interface utilisateur modernisée et cohérente, grâce à l'application du thème Adw-gtk3 sur votre système.

Pour intégrer OpenRGB, un outil permettant de contrôler l'éclairage RGB de divers périphériques sur Fedora Silverblue ou Kinoite, suivez ces instructions :

---

## Installation et Configuration d'[OpenRGB](https://openrgb.org)

1. **Installation des règles udev pour OpenRGB** :
    - Ceci est nécessaire pour permettre à OpenRGB de communiquer correctement avec votre matériel sans nécessiter de permissions root.
        ```bash
        sudo rpm-ostree install openrgb-udev-rules
        ```

2. **Installation d'OpenRGB via Flatpak** :
    - Pour installer l'application OpenRGB.
        ```bash
        flatpak install org.openrgb.OpenRGB
        ```

3. **Création d'un Profil OpenRGB** :
    - Après l'installation, lancez OpenRGB et configurez vos paramètres RGB. Enregistrez ces paramètres sous un profil nommé, par exemple, "fedora".

4. **Ajout d'OpenRGB au Démarrage** :
    - Ouvrez **Ajustements** dans GNOME.
    - Allez dans l'onglet **Applications au démarrage**.
    - Cliquez sur **+** et choisissez **OpenRGB** pour l'ajouter à la liste des applications lancées au démarrage de l'ordinateur.

5. **Configuration du Lancement Automatique du Profil** :
    - Pour que OpenRGB lance automatiquement votre profil "fedora" au démarrage de l'ordinateur et en mode minimisé, créez ou modifiez le fichier de lancement automatique :
        ```bash
        nano ~/.config/autostart/org.openrgb.OpenRGB.desktop
        ```
    - Remplacez la ligne existante commençant par `Exec=` avec :
        ```
        Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=openrgb org.openrgb.OpenRGB --startminimized --profile "fedora"
        ```
    - Sauvegardez et fermez l'éditeur. Cette configuration permettra à OpenRGB de démarrer en arrière-plan avec les paramètres de votre profil "fedora" chaque fois que vous allumerez votre ordinateur.
  
   Pour intégrer un guide spécifique à l'installation et à la configuration de Steam via Flatpak sur Fedora Silverblue ou Kinoite, suivez ces instructions détaillées :

---

## Steam Flatpak
Installation de Steam, configuration pour un démarrage en mode minimisé et ajout d'une bibliothèque de jeux sur un second disque.

### Installation de Steam et Configuration des Périphériques

1. **Installation des pilotes de périphériques pour Steam** :
    - Cette étape assure que tous les périphériques nécessaires pour Steam (comme les contrôleurs de jeu) fonctionnent correctement.
        ```bash
        sudo rpm-ostree install steam-devices
        ```

2. **Installation de Steam via Flatpak** :
    - Pour installer la version Flatpak de Steam, qui offre une meilleure intégration et isolation sur Fedora Silverblue et Kinoite.
        ```bash
        flatpak install com.valvesoftware.Steam
        ```

### Lancement Automatique de Steam en Mode Minimisé

1. **Configuration du démarrage automatique** :
    - Pour que Steam démarre automatiquement à l'ouverture de session, en mode minimisé, modifiez le fichier de démarrage automatique :
        ```bash
        nano ~/.config/autostart/com.valvesoftware.Steam.desktop
        ```
    - Ajoutez " -silent " entre %U et @@ dans la ligne `Exec=`, afin qu'elle ressemble à ceci :
        ```
        Exec=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/bin/steam --file-forwarding com.valvesoftware.Steam @@U %U -silent @@
        ```
    - Cette modification permet de lancer Steam automatiquement en arrière-plan, sans fenêtre de démarrage.

### Ajout d'un Second Disque de Jeux

1. **Configuration de l'accès à un second disque** :
    - Si vous souhaitez ajouter un second disque dur ou SSD pour votre bibliothèque de jeux Steam, vous devez accorder à Steam l'accès à ce disque via une surcharge Flatpak :
        ```bash
        flatpak override --user --filesystem=/chemin/vers/votre/Bibliothèque/Steam com.valvesoftware.Steam
        ```
    - Remplacez `/chemin/vers/votre/Bibliothèque/Steam` par le chemin réel vers votre dossier de bibliothèque Steam sur le second disque.
