#!/bin/bash
#   https://raw.githubusercontent.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/main/setupArchLinux.sh
#
#   Please make sure to enable multilib repository before running this script
#       https://wiki.archlinux.org/title/official_repositories#Enabling_multilib
#   
#   run this command 
#       sudo pacman -Syyuu wget
#
#   after it finishes make sure to reboot before running the script and after running it
#
#   DO NOT RUN AS SUDO/ROOT
#
#   Konsole shell blur
#
#   System settings > Desktop Effects > blur enable that
#   Next under Konsole create a mew profile and make the default
#   Go into appearance select a prefered theme and click on Edit on the right
#   There tick Blur background and set Bacground color transparency to 20%
#   Hit Apply and then Hit Ok
#

# Bash implementation of the pause command from bat scripts in Windows
function quit {
    echo -e "Script created by \e[1;32mBeanGreen247\e[1;0m \e[1;31mhttps://github.com/BeanGreen247 \e[1;0m\n"
    exit 1
}

function main {
    ### VARS
    echo -n "Enter username: "
    read usernameinput
    username="$usernameinput"
    echo -n "Enter root password: "
    read -s password
    pass="$password"
    echo -n "Enter gpu type [intel or amd or nvidia]: "
    read gpu
    gpudriver="$gpu"
    zramsize=32768 #check Setting up zram

    #cannot automate, causes issues
    #echo $pass |sudo -S echo "[multilib]" >> /etc/pacman.conf
    #echo $pass |sudo -S echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
    echo $pass | sudo -S pacman -Syyuu --noconfirm

    echo $pass | sudo -S pacman -S --noconfirm wget dos2unix sed
    wget -O /home/$username/.bashrc https://raw.githubusercontent.com/BeanGreen247/dotfiles/master/bashrc/bashrc-blue

    echo "Scripts Prep..."
    mkdir /home/$username/scripts
    wget -O /home/$username/scripts/fixLineEndings.sh https://raw.githubusercontent.com/BeanGreen247/scripts/main/scripts/fixLineEndings.sh
    wget -O /home/$username/scripts/execute-performance-mode-sh-as-root.sh https://raw.githubusercontent.com/BeanGreen247/scripts/main/scripts/execute_as_root.sh
    wget -O /home/$username/scripts/performance-mode.sh https://raw.githubusercontent.com/BeanGreen247/scripts/main/scripts/performance-mode.sh
    wget -O /home/$username/scripts/replaceString.sh https://raw.githubusercontent.com/BeanGreen247/scripts/main/scripts/replaceString.sh
    cd /home/$username/scripts
    bash replaceString.sh not_gonna_dox_myself $pass
    bash fixLineEndings.sh
    cd

    echo -e '\e[1;31m[IMPORTANT MESSAGE, PLEASE READ]\e[1;0m\n'
    echo 'The following scripts were created, make sure to add execute_as_root.sh to startup items.'
    echo '/home/'$username'/scripts/performance-mode.sh'
    echo '/home/'$username'/scripts/execute_as_root.sh'
    echo 'Make sure to ceck if the password is set correctly in the scripts.'
    echo 'Visit https://github.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script#to-expand-on-the-autostart-portion-of-the-script for more information.'
    echo -e "Scripts Prep...\e[1;32m[DONE]\e[1;0m"

    echo -e "\e[1;31m[Will resume in 30s...]\e[1;0m\n"
    sleep 30
    echo 'Installing GUI, apps and other packages...'
    echo $pass | sudo -S pacman -S --noconfirm --needed grub-customizer htop btop nemo neofetch xorg cpupower firefox pulseaudio libreoffice base-devel git vim vi cronie net-tools linux-headers asp plasma plasma-wayland-session kde-applications obs-studio jre-openjdk jre11-openjdk jre8-openjdk jdk-openjdk jdk11-openjdk jdk8-openjdk gcc glibc gamemode lib32-gamemode lib32-vkd3d vkd3d git-lfs tmux filezilla ksysguard fakeroot zram-generator sddm-kcm audacious nss-mdns pulseaudio-bluetooth pulseaudio-alsa bluez-utils handbrake unrar mpv smbclient gvfs-smb nemo-share dbus avahi python3 python-pip gobject-introspection
    echo $pass | sudo -S systemctl enable cronie sddm avahi-daemon
    echo $pass | sudo -S pacman -S --noconfirm --needed giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader cups samba alsa alsa-utils alsa-tools gnutls libpng wine-mono lib32-libxml2 lib32-mpg123 lib32-lcms2 lib32-giflib lib32-libpng lib32-gnutls pygtk python2-dbus lib32-libpulse lib32-fontconfig lib32-libxcomposite lib32-libxrender  lib32-libxslt lib32-gnutls lib32-libxi lib32-libxrandr lib32-libxinerama lib32-libcups lib32-freetype2 lib32-libpng lib32-openal python-pyopencl lib32-v4l-utils lib32-libxcursor lib32-mpg123 lib32-sdl xf86-video-intel lib32-mesa-libgl nss-mdns
    echo $pass | sudo -S systemctl enable cpupower
    echo $pass | sudo -S systemctl start cpupower
    echo -e "Installing GUI, apps and other packages...\e[1;32m[DONE]\e[1;0m"
    
    echo 'Getting btop configuration...'
    wget -O /home/$username/.config/btop/btop.conf https://raw.githubusercontent.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/main/btop.conf
    echo 'Getting btop configuration...\e[1;32m[DONE]\e[1;0m'

    echo -e "\e[1;31m[Setting up zram...]\e[1;0m\n"
    echo $pass | sudo -S echo '# This config file enables a /dev/zram0 device with the default settings:' | sudo tee /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S echo '# - size - same as available RAM or 32GB, whichever is less' | sudo tee -a /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S echo '#        - if your system/VM has 16GB RAM then change it from 32768 to 16384' | sudo tee -a /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S echo '# - compression - most likely lzo-rle' | sudo tee -a /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S echo '# To disable, uninstall zram-generator-defaults or create empty' | sudo tee -a /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S echo '# /etc/systemd/zram-generator.conf file.' | sudo tee -a /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S echo '[zram0]' | sudo tee -a /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S echo 'zram-size = min(ram, '$zramsize')' | sudo tee -a /usr/lib/systemd/zram-generator.conf
    echo $pass | sudo -S systemctl daemon-reload
    echo $pass | sudo -S systemctl start /dev/zram0
    echo $pass | sudo -S zramctl
    echo -e "Setting up zram...\e[1;32m[DONE]\e[1;0m"

    echo 'Installing GPU Drivers...'
    if [ "$gpudriver" == "amd" ]; then
        #AMD
        echo -e "\e[1;31m[AMD GPU Drivers Selected]\e[1;0m\n"
        echo $pass | sudo -S pacman -S --needed --noconfirm vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk vulkan-icd-loader lib32-vulkan-icd-loader vulkan-mesa-layers lib32-vulkan-mesa-layers
    elif [ "$gpudriver" == "nvidia" ]; then
        #NVIDIA
        echo -e "\e[1;31m[NVIDIA GPU Drivers Selected]\e[1;0m\n"
        echo $pass | sudo -S pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader vulkan-mesa-layers lib32-vulkan-mesa-layers
    else
        #INTEL
        echo -e "\e[1;31m[INTEL GPU Drivers Selected]\e[1;0m\n"
        echo $pass | sudo -S pacman -S --needed mesa lib32-mesa xf86-video-intel vulkan-intel lib32-vulkan-intel intel-media-driver vulkan-icd-loader lib32-vulkan-icd-loader vulkan-mesa-layers lib32-vulkan-mesa-layers
    fi
    echo -e 'Installing GPU Drivers...\e[1;32m[DONE]\e[1;0m'

    echo -e '\e[1;31m[In about 5 - 10s your input will be required]\e[1;0m\n'
    sleep 10
    echo 'Installing virt-manager and other virtual machine stuff...'
    echo $pass | sudo -S pacman -Sy
    echo $pass | sudo -S pacman -S virt-manager qemu-base dnsmasq swtpm qemu-base qemu-block-gluster qemu-block-iscsi dnsmasq qemu-audio-pa libvirt libxml2 python3 python-pip gobject-introspection
    python -m pip install catfish pygobject libvirt-python requests --user
    echo $pass | sudo -S systemctl enable libvirtd
    echo $pass | sudo -S systemctl start libvirtd
    echo $pass | sudo -S systemctl restart libvirtd
    echo $pass | sudo -S virsh net-start default
    echo $pass | sudo -S virsh net-autostart default
    echo -e 'Installing virt-manager and other virtual machine stuff...\e[1;32m[DONE]\e[1;0m'

    echo 'Installing Joplin note taking app...'
    wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
    echo 'Installing Joplin note taking app...\e[1;32m[DONE]\e[1;0m'

    echo -e '\e[1;31m[In about 5 - 30s your input will be required]\e[1;0m\n'
    echo 'Please wait 30s before script continues...'
    echo 'Make sure to have your password for your root account ready, should be the same pass you use to log in...'
    sleep 30

    echo 'Installing yay...'
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd
    echo -e 'Installing yay...\e[1;32m[DONE]\e[1;0m'

    echo 'Installing VNC Viewer...'
    yay -S realvnc-vnc-viewer
    echo 'Installing VNC Viewer...\e[1;32m[DONE]\e[1;0m'

    echo 'Installing Visual Studio Code...'
    yay -S visual-studio-code-bin
    echo -e 'Installing Visual Studio Code...\e[1;32m[DONE]\e[1;0m'

    echo 'Installing Tools for CPU freq managment...'
    yay -S auto-cpufreq
    systemctl enable --now auto-cpufreq
    echo -e 'Installing Tools for CPU freq managment...\e[1;32m[DONE]\e[1;0m'

    echo 'Installing Fonts and Gaming stuff...'
    yay -S discord dxvk-bin mangohud goverlay ttf-ms-win11-auto
    echo 'Installing nerd font...'
    echo $pass | sudo -S pacman -S --noconfirm otf-aurulent-nerd otf-cascadia-code-nerd otf-codenewroman-nerd otf-droid-nerd otf-firamono-nerd otf-hasklig-nerd otf-hermit-nerd otf-opendyslexic-nerd otf-overpass-nerd ttf-3270-nerd ttf-agave-nerd ttf-anonymouspro-nerd ttf-arimo-nerd ttf-bigblueterminal-nerd ttf-bitstream-vera-mono-nerd ttf-cousine-nerd ttf-daddytime-mono-nerd ttf-dejavu-nerd ttf-fantasque-nerd ttf-firacode-nerd ttf-go-nerd ttf-hack-nerd ttf-heavydata-nerd ttf-iawriter-nerd ttf-ibmplex-mono-nerd ttf-inconsolata-go-nerd ttf-inconsolata-lgc-nerd ttf-inconsolata-nerd ttf-iosevka-nerd ttf-jetbrains-mono-nerd ttf-lekton-nerd ttf-liberation-mono-nerd ttf-lilex-nerd ttf-meslo-nerd ttf-monofur-nerd ttf-monoid-nerd ttf-mononoki-nerd ttf-mplus-nerd ttf-nerd-fonts-symbols-common ttf-noto-nerd ttf-profont-nerd ttf-proggyclean-nerd ttf-roboto-mono-nerd ttf-sharetech-mono-nerd ttf-sourcecodepro-nerd ttf-space-mono-nerd ttf-terminus-nerd ttf-tinos-nerd ttf-ubuntu-mono-nerd ttf-ubuntu-nerd ttf-victor-mono-nerd
    echo 'Installing japanese font...'
    echo $pass | sudo -S pacman -S --noconfirm noto-fonts-cjk noto-fonts-emoji noto-fonts
    echo -e 'Installing font symbols...\e[1;32m[DONE]\e[1;0m'
    echo -e 'Installing Fonts and Gaming stuff...\e[1;32m[DONE]\e[1;0m'
    
    echo 'Getting current pacman.conf file...'
    wget -O /home/$username/pacman.conf https://raw.githubusercontent.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/main/pacman.conf
    echo $pass | sudo -S cp -r /home/$username/pacman.conf /etc/pacman.conf
    rm -rf /home/$username/pacman.conf
    echo -e 'Getting current pacman.conf file...\e[1;32m[DONE]\e[1;0m'
    
    echo 'Getting neofetch theme...'
    git clone https://github.com/Chick2D/neofetch-themes
    cd /home/$username/.config/neofetch/ && rename config.conf config.conf.bak config.conf
    cd /home/$username/
    cp -r neofetch-themes/normal/ozozfetch /home/$username/.config/neofetch/config.conf
    rm -rf /home/$username/neofetch-themes
    echo -e 'Getting neofetch theme...\e[1;32m[DONE]\e[1;0m'
    
    echo -e "Script created by \e[1;32mBeanGreen247\e[1;0m \e[1;31mhttps://github.com/BeanGreen247 \e[1;0m\n"

    exit 1
}

echo -e "\e[1;31m[BeanGreen247's KDE Plasma setup script]\e[1;0m\n"
echo -e "\e[1;31m[Hello! This script is intended for personal use or as inspiration for others to have a automated KDE Plasma setup on Arch Linux.]\e[1;0m"
echo -e "\e[1;31m[This script has been tested multiple times on devVMs and testing VMs to ensure that no issues appear.]\e[1;0m"
echo -e "\e[1;31m[In case any issues do appear make sure to highlight them in issues on this scripts github page here https://github.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script/issues]\e[1;0m\n"
echo -e "\e[1;31m[For more information about this script make sure to visit https://github.com/BeanGreen247/ArchLinux-KDE-Plasma-setup-script]\e[1;0m"
echo "Waiting for user to press any key or Q to quit..."
read -rsn1 input
if [ "$input" = "q" ]; then
    quit
else
    main
fi
