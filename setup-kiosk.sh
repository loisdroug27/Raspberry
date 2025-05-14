#!/bin/bash

echo "== Updating system =="
sudo apt update && sudo apt upgrade -y

echo "== Installing Chromium, Plymouth, and Unclutter =="
sudo apt install -y chromium-browser plymouth plymouth-themes unclutter

echo "== Creating autostart folder =="
mkdir -p ~/.config/autostart

echo "== Creating kiosk autostart desktop file =="
cat > ~/.config/autostart/kiosk.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Kiosk
Exec=sh -c "unclutter --timeout 0 --jitter 0 --daemon & chromium-browser --kiosk --app=file:///media/pi/WEBSITE/index.html --autoplay-policy=no-user-gesture-required --disable-infobars --disable-features=TranslateUI"
X-GNOME-Autostart-enabled=true
EOF

echo "== Configuring Plymouth (clean boot splash) =="
sudo plymouth-set-default-theme fade-in -R

echo "== Updating cmdline.txt for quiet boot =="
sudo sed -i 's/console=serial0,115200 console=tty1 //' /boot/firmware/cmdline.txt
sudo sed -i 's/$/ quiet splash plymouth.ignore-serial-consoles vt.global_cursor_default=0/' /boot/firmware/cmdline.txt

echo "== Disabling rainbow splash screen =="
sudo sed -i '$a disable_splash=1' /boot/firmware/config.txt

echo "== Disabling screen blanking =="
sudo raspi-config nonint do_blanking 1

echo "== DONE! Rebooting in 10 seconds =="
sleep 10
sudo reboot
