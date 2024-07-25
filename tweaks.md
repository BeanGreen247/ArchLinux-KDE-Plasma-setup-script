some more packages

Please make sure to enable multilib repository

https://wiki.archlinux.org/title/official_repositories#Enabling_multilib
```bash
sudo pacman -Syy
sudo pacman -S base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```
```bash
sudo pacman -S sane hplip cups system-config-printer simple-scan pulseaudio-bluetooth gst-plugins-bad bluez blueman gst-plugins-bad pulseaudio-alsa bluez-utils handbrake
sudo systemctl enable --now cups
sudo systemctl enable --now bluetooth.service
```
```bash
sudo pacman -S mpg123 flac jack libmpcdec pulseaudio pipewire libcdio-paranoia libcddb libmms libmodplug libsndfile projectm faad2 libgme libsidplayfp opusfile wildmidi ffmpeg libsamplerate wavpack gamemode lib32-gamemode lib32-vkd3d vkd3d git-lfs ksysguard fakeroot nss-mdns unrar mpv gvfs-smb nemo-share dbus avahi python3 python-pip gobject-introspection
```
```bash
sudo pacman -S terminus-font ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid gnu-free-fonts ttf-ibm-plex ttf-input ttf-liberation libertinus-font noto-fonts gsfonts gnu-free-fonts tex-gyre-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code ttf-fantasque-sans-mono otf-fantasque-sans-mono ttf-fira-mono otf-fira-mono ttf-fira-code ttf-hack otf-hermit ttf-inconsolata ttc-iosevka ttf-jetbrains-mono ttf-monofur ttf-roboto-mono ttf-roboto adobe-source-code-pro-fonts cantarell-fonts ttf-fira-sans otf-fira-sans gnu-free-fonts inter-font ttf-liberation otf-montserrat ttf-nunito ttf-opensans adobe-source-sans-fonts otf-crimson gnu-free-fonts ttf-gentium-plus ttf-liberation ttf-linux-libertine libertinus-font tex-gyre-fonts ttf-croscore ttf-junicode xorg-fonts-type1 adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk ttf-hannom ttf-croscore gnu-free-fonts ttf-khmer ttf-tibetan-machine noto-fonts-emoji ttf-joypixels ttf-font-awesome  gnu-free-fonts ttf-arphic-uming ttf-indic-otf otf-latin-modern otf-latinmodern-math libertinus-font texlive-basic texlive-fontsextra
```
```bash
yay -S all-repository-fonts pcf-spectrum-berry dina-font efont-unicode-bdf gohufont artwiz-fonts ttf-profont-iix proggyfonts tamsyn-font bdf-tewi-git bdf-unifont profont-otb xorg-fonts-misc-otb gohufont-otb cozette-otb ttf-ms-win10 ttf-b612 font-bh-ttf ttf-ms-fonts ttf-vista-fonts ttf-google-fonts-git ttf-courier-prime ttf-envy-code-r otf-hasklig ttf-inconsolata-g tf-lilex jre ttf-meslo ttf-monaco ttf-mononoki ttf-comic-mono-git ttf-andika ttf-dmcasansserif otf-jost ttf-tahoma ttf-bitstream-charter otf-bitstream-charter otf-bodoni ebgaramond-otf ttf-heuristica ttf-librebaskerville otf-libre-caslon ttf-nothingyoucoulddo ttf-indieflower ttf-pacifico otf-londrina otf-tesla ttf-architects-daughter ttf-cheapskate ttf-mph-2b-damase ttf-ancient-fonts ttf-ubraille ttf-paratype otf-russkopis otf-gfs ttf-mgopen ttf-sbl-greek ttf-sbl-biblit opensiddur-hebrew-fonts culmus alefbet ttf-ms-fonts ttf-sbl-hebrew ttf-sbl-biblit ttf-everson-mono ttf-abkai persian-fonts borna-fonts iran-nastaliq-fonts iranian-fonts ir-standard-fonts persian-hm-ftx-fonts persian-hm-xs2-fonts gandom-fonts parastoo-fonts sahel-fonts samim-fonts shabnam-fonts tanha-fonts vazirmatn-fonts vazir-code-fonts ttf-yas ttf-x2 fonts-tlwg ttf-google-thai ttf-lao ttf-sil-padauk ttf-twemoji otf-openmoji ttf-twemoji-color ttf-symbola ttf-teranoptia-furiae ttf-cm-unicode otf-cm-unicode otf-stix tex-gyre-math-fonts ttf-mac-fonts ttf-lilex
```
/etc/default/grub
```
#GRUB_CMDLINE_LINUX_DEFAULT='quiet resume=UUID=388d651f-6792-433b-b9a3-1016ba47524b loglevel=3'
GRUB_CMDLINE_LINUX_DEFAULT='ipv6.disable=1 sysrq_always_enabled=1 rootflags=noatime consoleblank=0 pti=on ibt=off split_lock_detect=off split_lock_mitigate=0 intel_pstate=disable mitigations=off spec_store_bypass_disable spectre_v2 nosoftlockup nowatchdog nomce noirqdebug thermal.off=1 timer_migration=0 quiet resume=UUID=388d651f-6792-433b-b9a3-1016ba47524b loglevel=0 udev.log_level=0 rd.udev.log_level=0 audit=0 acpi_enforce_resources=lax'
#GRUB_CMDLINE_LINUX=""
GRUB_CMDLINE_LINUX="vdso=0 vdso32=0 ignore_rlimit_data preempt=full nohz_full=all threadirqs"
```

* intel_pstate=disable -> disables turbo boost
  * some note about lower latency

`sudo grub-mkconfig -o /boot/grub/grub.cfg`

`rate-mirrors --allow-root --protocol https arch | grep -v '^#' | sudo tee /etc/pacman.d/mirrorlist`

sudo nano /etc/udev/rules.d/81-wifi-powersave.rules
```
ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="/usr/bin/iw dev $name set power_save off"
```
#### for kde plasma reference the main script

or
```bash
sudo pacman -Syy xorg plasma plasma-wayland-session kde-applications plasma-desktop plasma5-integration plasma-pa plasma5support plasma-pass plasma-activities plasma-sdk plasma-activities-stats plasma-systemmonitor plasma-applet-window-buttons plasma-thunderbolt plasma-browser-integration plasmatube plasma-disks plasma-vault plasma-firewall plasma-wayland-protocols plasma-framework5 plasma-welcome plasma-integration plasma-workspace plasma-meta plasma-workspace-wallpapers plasma-nm qt5-wayland qt6-wayland libdecor glfw xdg-desktop-portal wlroots wayland-protocols kwin xorg-xinput xorg-xinit xorg-xwayland xorg-xgamma xorg-xhost xorg-xdm xorg-xdpyinfo xorg-xdriinfo xorg-xedit xorg-xev xorg-xcursorgen xorg-xclipboard xorg-xcmsdb xorg-xconsole xorg-xcalc xorg-xbacklight xorg-xauth xorg-x11perf xorg-util-macros xorg-server xorg-setxkbmap xorg-xkbcomp xorg-xkbevd xorg-fonts-100dpi xorg-fonts-alias-cyrillic xorg-fonts-misc xorg-fonts-75dpi xorg-fonts-alias-misc xorg-fonts-type1 xorg-fonts-alias-100dpi xorg-fonts-cyrillic xorg-fonttosfnt xorg-fonts-alias-75dpi xorg-fonts-encodings xorg-font-util
```

or
```bash
sudo pacman -Syy xorg xdg-desktop-portal wlroots wayland-protocols libinput wayland pkg-config libxcb xwaylandvideobridge xorg-xwayland plasma dolphin kate konsole
```
