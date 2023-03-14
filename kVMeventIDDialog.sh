#!/bin/bash
#
# This script creates a dialog at startup that shows current eventIDs to be used in kVMs
#
keyboardEventID=$(ls -al /dev/input/by-id | grep usb-LIZHI_Flash_IC_USB_Keyboard-event-kbd | awk {'print $10'} | cut -c 4-)
mouseEventID=$(ls -al /dev/input/by-id | grep usb-KYE_SYSTEMS_CORP._Wired_Mouse-event-mouse | awk {'print $10'} | cut -c 4-)
echo "Keyboard Event ID: $keyboardEventID" > eventIDs.txt
echo "Mouse Event ID: $mouseEventID" >> eventIDs.txt
echo "Make sure to adjust your kVM XML/settings for input devices" >> eventIDs.txt
echo "" >> eventIDs.txt
echo "For mouse" >> eventIDs.txt
echo "" >> eventIDs.txt
echo '<input type="evdev">' >> eventIDs.txt
echo '  <source dev="/dev/input/'$mouseEventID'"/>' >> eventIDs.txt
echo '</input>' >> eventIDs.txt
echo "" >> eventIDs.txt
echo "For Keyboard" >> eventIDs.txt
echo "" >> eventIDs.txt
echo '<input type="evdev">' >> eventIDs.txt
echo '  <source dev="/dev/input/'$keyboardEventID'" grab="all" repeat="on"/>' >> eventIDs.txt
echo '</input>' >> eventIDs.txt
echo "" >> eventIDs.txt
echo "just make sure to copy into the right places" >> eventIDs.txt
echo "" >> eventIDs.txt
echo "incase the vm does not want to power down use the powerDownAllVMs.sh script that can be found in the scripts folder and can be executed like this" >> eventIDs.txt
echo "" >> eventIDs.txt
echo "bash scripts/powerDownAllVMs.sh" >> eventIDs.txt

kdialog --title "EventIDs for kVMs" --textbox eventIDs.txt 512 512
