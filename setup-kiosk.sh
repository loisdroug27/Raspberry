#!/bin/bash

echo "== Updating system =="
sudo apt update && sudo apt upgrade -y

echo "== Installing Chromium, Plymouth, and Unclutter =="
sudo apt install -y chromium-browser plymouth plymouth-themes unclutter

echo "== Disabling Bluetooth =="
sudo systemctl disable bluetooth
sudo systemctl mask bluetooth
sudo rfkill block bluetooth

echo "== Configuring autostart to launch Chromium fullscreen =="
mkdir -p ~/.config/lxsession/LXDE-pi/
cat > ~/.config/lxsession/LXDE-pi/autostart <<EOF
@xset s off
@xset -dpms
@xset s noblank
@unclutter --timeout 0 --jitter 0 --daemon
@chromium-browser --kiosk --app=file:///media/pi/WEBSITE/index.html --autoplay-policy=no-user-gesture-required --disable-infobars --disable-features=TranslateUI
EOF

echo "== Hiding desktop icons and panel =="
mkdir -p ~/.config/pcmanfm/LXDE-pi
cat > ~/.config/pcmanfm/LXDE-pi/desktop-items-0.conf <<EOF
[*]
wallpaper_mode=color
desktop_bg=#000000
desktop_fg=#ffffff
desktop_shadow=false
desktop_font=Sans 12
show_wm_menu=false
sort=mtime;ascending;
show_documents=false
show_trash=false
show_mounts=false
EOF

echo "== Creating Chromium autostart entry =="
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/kiosk.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Kiosk
Exec=lxsession -s LXDE-pi -e LXDE
X-GNOME-Autostart-enabled=true
EOF

echo "== Installing Website Touch Kiosk Plymouth Theme =="
mkdir -p /usr/share/plymouth/themes/website-kiosk
wget -O /tmp/website-kiosk.zip "https://github.com/loisdroug27/Raspberry/raw/main/Plymouth%20theme/website-kiosk-plymouth.zip"
sudo unzip -o /tmp/website-kiosk.zip -d /usr/share/plymouth/themes/website-kiosk
sudo plymouth-set-default-theme -R website-kiosk

echo "== Configuring clean boot settings =="
sudo sed -i 's/console=serial0,115200 console=tty1 //' /boot/firmware/cmdline.txt
sudo sed -i 's/$/ quiet splash plymouth.ignore-serial-consoles vt.global_cursor_default=0/' /boot/firmware/cmdline.txt

echo "== Disabling rainbow splash =="
sudo sed -i '$a disable_splash=1' /boot/firmware/config.txt

echo "== Disabling screen blanking =="
sudo raspi-config nonint do_blanking 1

echo "== Setup complete. Rebooting in 10 seconds... =="
sleep 10
sudo reboot
