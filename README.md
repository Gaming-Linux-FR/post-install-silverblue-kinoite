# Configuration de Fedora Silverblue ou Kinoite

## Table des Matières

- **[Flatpak ou RPM ?](#flatpak-ou-rpm)**
- **[Pilotes Nvidia](#pilotes-nvidia)**
- **[AMD & Intel](#amd--intel)**
- **[Installation d'Applications avec rpm-ostree](#installation-dapplications-avec-rpm-ostree)**
- **[Installation d'Applications avec flatpak](#installation-dapplications-avec-flatpak)**
- **[Ajout de Dépôts RPM Fusion](#ajout-de-dépôts-rpm-fusion)**
- **[Firefox avec CODEC](#firefox-avec-codec)**
- **[Rebase du Système](#rebase-du-système)**
- **[Restauration du Système (Rollback)](#restauration-du-système-rollback)**
- **[Installation de xpadneo](#installation-de-xpadneo)**
- **[Avoir les Gestes au Pavé Tactile sur Gnome X11](#avoir-les-gestes-au-pavé-tactile-sur-gnome-x11)**
- **[Personnalisation de l'Apparence avec Adw-gtk3](#personnalisation-de-lapparence-avec-adw-gtk3)**
- **[Installation et Configuration d'OpenRGB](#installation-et-configuration-dopenrgb)**
- **[Steam Flatpak](#steam-flatpak)**
- **[Multi boot](#multi-boot)**
- **[Problèmes divers](#problèmes-divers)**

--- 

<br>

## Flatpak ou RPM 

La décision d'utiliser Flatpak ou des paquets RPM sur Fedora Silverblue/Kinoite dépend largement de vos préférences personnelles, car chaque méthode présente ses propres avantages et inconvénients.

- **Paquets RPM** : Installés avec `rpm-ostree install`, les paquets RPM sont intégrés directement dans le système. L'installation ou la mise à jour de paquets RPM nécessite un redémarrage du système pour être effective, en raison du caractère immuable de ces distributions. Cela peut être perçu comme une contrainte, surtout si vous recherchez une flexibilité et une mise à jour rapide de vos applications. Les paquets RPM sont officiellement fournis par Fedora, ce qui peut offrir une certaine assurance quant à leur qualité et leur suivi.

- **Flatpak** : Installés par Gnome Logiciel / Discover ou commande `flatpak install`. Cette méthode offre souvent des versions d'applications plus récentes et une isolation par rapport au système, ce qui peut améliorer la stabilité et la compatibilité des applications ainsi que augmenter la protection de votre vie privée. Cependant, l'utilisation de Flatpak peut exiger une gestion manuelle des permissions, par exemple pour permettre à une application comme Steam d'accéder à un second disque dur. Bien que Flatpak puisse offrir une plus grande flexibilité et des mises à jour plus fréquentes, certains paquets sont maintenus par la communauté et peuvent donc être sujets à des problèmes de suivi ou être abandonnés.

--- 

<br>

## Ajout de Dépôts RPM Fusion
Indispensable pour beaucoup de choses dont *Nvidia* :
```bash
sudo rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release 
```

Si erreur : ```error: Package/capability 'rpmfusion-free-release' is already requested```  C'était déjà fait, on peut passer à la suite.

---
## Pilotes Nvidia
> [!IMPORTANT]
>  Quel que soit le DE et la distribution, restez sur *X11* au moins jusqu'à ce que ce patch arrive dans votre distro. : [explicit-sync](https://gitlab.freedesktop.org/xorg/xserver/-/merge_requests/967),
>  Désactivez le Secure Boot dans le BIOS/UEFI de l'ordinateur pour permettre l'installation des modules [DKMS](https://wiki.archlinux.org/title/Dynamic_Kernel_Module_Support_(Fran%C3%A7ais)), essentiels pour les pilotes Nvidia mais aussi par exemple pour Xpadneo bien utile pour les manettes Xbox recentes.

**Script pour automatiser l'instalation des drivers Nvidia :**
```bash
git clone https://github.com/Gaming-Linux-FR/post-install-silverblue-kinoite.git ~/post-install-silverblue-kinoite && cd ~/post-install-silverblue-kinoite && chmod +x ./nvidia.sh && sudo ./nvidia.sh
```

**Si vous préférez le faire vous même suivez les étapes suivantes :**

- Ajout du driver et des options kernel
```bash
sudo rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-libs
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

<br>

## AMD & Intel
Pris en charge nativement.

--- 

<br>

## Installation d'Applications avec rpm-ostree
La commande est : ``rpm-ostree install nomdespaquets`` exemple :

```bash
sudo rpm-ostree install fastfetch lutris goverlay wine steam
```

--- 

<br>

## Installation d'Applications avec flatpak

Vous pouvez simplement passer par *Gnome logiciel* sur Silverblue ou *Discover* sur Kinoite. Attention de bien selectionner la source flathub en haut à droite.

--- 

<br>

## Firefox avec CODEC
Pour assurer la prise en charge complète des codecs dans Firefox sur Fedora Silverblue/Kinoite, permettant ainsi la lecture de toutes les vidéos.

**Première solution**, suivez ces étapes pour remplacer la version par défaut de Firefox par celle disponible via Flatpak de Flathub :

1. **Supprimez Firefox installé par défaut** :
    - Exécutez la commande suivante pour retirer Firefox et ses paquets de langues associés du système :
        ```bash
        rpm-ostree override remove firefox firefox-langpacks
        ```

2. **Installez Firefox via Flatpak** :
    - Ouvrez **Gnome Software** ou **Discover**.
    - Recherchez **Firefox**.
    - Assurez-vous de sélectionner la version provenant de **Flathub** et non celle du dépôt Fedora.
    - Cliquez sur **Installer** pour procéder à l'installation.

Cette méthode vous permet d'accéder à une version de Firefox intégrant nativement le support étendu des codecs, indispensable pour une expérience de navigation optimale, notamment pour la lecture vidéo. Opter pour la version Flatpak de Flathub garantit également que vous bénéficiez des mises à jour directes de l'application, indépendamment des cycles de mise à jour du système d'exploitation.

**Seconde solution**, si vous préférez rester sur le Firefox rpm, installer le paquet `libavcodec-freeworld`, il devrait suffire pour la plus part des usages. Il faut avoir préalablement activé les dépots rpm-fusion.

```sh
rpm-ostree install --apply-live libavcodec-freeworld
```

--- 

<br>

## Rebase du système

Rebase permet de passer d'une Fedora immuable à une autre.

Passer sur Silverblue 40 qui est au moment ou j'écris ses lignes en phase de testing :
```bash
rpm-ostree rebase fedora:fedora/40/x86_64/silverblue
```
- Pour revenir à Silverblue 39 l'actuelle release : `rpm-ostree rebase fedora:fedora/39/x86_64/silverblue`

Pour Kinoite : 

- Pour passer à Kinoite 40 : `rpm-ostree rebase fedora:fedora/40/x86_64/kinoite`
- Pour revenir à Kinoite 39 : `rpm-ostree rebase fedora:fedora/39/x86_64/kinoite`

Pour les versions de développement remplacer le numéro de version par rawhide :

exemples :

- Pour passer à Kinoite Rawhide    : `rpm-ostree rebase fedora:fedora/rawhide/x86_64/kinoite`
- Pour passer à Silverblue Rawhide : `rpm-ostree rebase fedora:fedora/rawhine/x86_64/silverblue`

On peut passer de Kinoite à Silverblue sans problème, il faut juste reboot après une rebase. Si jamais il y a un problème on peut booter sur l'ancienne entrée et rollback pour la repasser en entrée principale.

--- 

<br>

## Restauration du Système (Rollback)
- **Temporaire** : Redémarrez et sélectionnez la version précédente dans le menu de démarrage.
- **Permanent** : Utilisez `sudo rpm-ostree rollback` sur le système que vous voulez garder et mettre en priorité au boot.

--- 

<br>

## Installation de [xpadneo](https://github.com/atar-axis/xpadneo)

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

Les utilisateurs préférant rester encore un peu sur X11 peuvent améliorer leur expérience en activant les gestes tactiles, ce qui rend la navigation et l'interaction avec le système d'exploitation plus intuitives et fluides.

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

<br>

## Personnalisation de l'Apparence avec Adw-gtk3
**Uniquement utile sur SILVERBLUE**

Pour personnaliser l'apparence de votre Fedora Silverblue avec le thème Adw-gtk3, suivez ces étapes :

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

--- 

<br>

## Installation et Configuration d'[OpenRGB](https://openrgb.org)

OpenRGB est un outil permettant de contrôler l'éclairage RGB de divers périphériques.

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

--- 

<br>

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

--- 

<br>

## Multi Boot

Comment ajouter une entrée dans le grub pour vos autres OS.

Détecter les autres OS :

```sh
sudo os-prober
```

Puis les ajouter au grub :

```sh
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

Et voilà en 2 commandes vous retrouverez vos autres systèmes d'exploitation dans le grub de Kinoite / Silverblue.

--- 

<br>

## Problèmes divers

Voir ce lien : [GLF ASTUCES](https://github.com/Gaming-Linux-FR/glf-astuces/edit/main/README.md)
