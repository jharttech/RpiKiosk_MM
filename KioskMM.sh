#!/bin/bash
set -x
#######################################################

# This script will help do the heavy lifting when 
# setting up a MagicMirror2 Client


#######################################################
# Global Declarations

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

exec 3>&1


#######################################################
sudo apt install dialog
# Logo Call
dialog  --title "Jharttech" \
        --clear \
        --timeout 1 \
        --exit-label "" \
        --textbox /usr/local/bin/logo.txt 0 0

######################################################

sudo apt-get update|dialog  --title "Updating Sources" \
        --clear \
        --progressbox 100 100


dialog --title "Tool Check" \
        --msgbox "Going to check for needed tools.\n\nIf they are not found they will be installed." 0 0
_PKG_OK=$(dpkg-query -W --showformat='${Status}\n' unclutter|grep "install ok installed")
if [ "" == "$_PKG_OK" ]; then
        dialog --title "unclutter check" \
                --msgbox "No unclutter tool found.\n\nInstalling and Setting up unclutter now." 0 0
        sudo apt-get -y install unclutter|dialog --title "Installing unclutter" \
                --clear \
                --progressbox 100 100
fi

_PKG_OKTwo=$(dpkg-query -W --showformat='${Status}\n' vim|grep "install ok installed")
if [ "" == "$_PKG_OKTwo" ]; then
        --and-widget --title "vim check" \
                --msgbox "No vim editor found.\n\nInstalling and Setting up vim now." 0 0
        sudo apt-get -y install vim|dialog --title "Installing vim" \
                --clear \
                --progressbox 100 100
fi


#######################################################

# Now going to install the lastes Node.js version
dialog --title "Install Nodejs" \
	--clear \
	--yes-label "Ok" \
	--no-label "Exit" \
	--yesno "Going to install latest Node.js version." 0 0
yn=$?
if [ "${yn}" == "0" ];
then
	clear
	curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
	sudo apt install -y nodejs
	break
else
	if [ "${yn}" == "1" ];
	then
		exit
	fi
fi

##########################################################

# Now going to clone in the MagicMirror Master Branch

clear
cd ~/
git clone https://github.com/MichMich/MagicMirror
cd MagicMirror
npm install

##########################################################

# Now going to setup the Rpi Client for use as MagicMirror
# client

# Here we turn on Open GL Driver to decrease Electron CPU Usage
# Make a Backup of original config file
sudo cp /boot/config.txt /boot/config.txt.original
while true; do
	_Prev_Ran=$(ls /boot/ | grep "config.txt.KioskMMBackup")
	if [ "" == "$_Prev_Ran" ];
	then
		sudo cp /boot/config.txt /boot/config.txt.KioskMMBackup
		dialog --title "Open GL Driver" \
			--clear \
			--timeout 5 \
			--msgbox "Now writing the following entry to the config file.\n\n#Turn on OpenGL Driver.\ndtoverlay=vc4-kms-v3d" 0 0
		echo -e "# Turn on Open GL Driver.\ndtoverlay=vc4-kms-v3d" | sudo tee -a /boot/config.txt
		break
	else
		sudo mv /boot/config.txt.KioskMMBackup /boot/config.txt
		break
	fi
done

while true; do
	_Prev_RanTwo=$(ls /etc/xdg/lxsession/LXDE-pi/ | grep "autostart.KioskMMBackup")
	if [ "" = "$_Prev_RanTwo" ];
	then
		# Make a copy of original config file
		sudo cp /etc/xdg/lxsession/LXDE-pi/autostart /etc/xdg/lxsession/LXDE-pi/autostart.original
		sudo cp /etc/xdg/lxsession/LXDE-pi/autostart /etc/xdg/lxsession/LXDE-pi/autostart.KioskMMBackup
		dialog --title "Screen Orientation" \
			--clear \
			--yesno "The default screen layout is landscape.\n\nWould you like to rotate the screen layout to portrait?" 0 0
		yn=$?
		if [ "${yn}" == "0" ];
		then
			dialog --title "Rotate Screen" \
				--clear \
				--yes-label "Rotate Right" \
				--no-label "Rotate Left" \
				--yesno "Please select which direction you would like to rotate your display." 0 0
			yn=$?
			if [ "${yn}" == "0" ];
			then
				dialog --title "Rotate Right" \
					--timeout 4 \
					--msgbox "Now writing the following entries to autostart file.\n\n# Rotate screen right.\n@xrandr --output HDMI-1 --rotate right" 0 0
				echo -e "# Rotate screen right\n@xrandr --output HDMI-1 --rotate right" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart > /dev/null
				break
			else
				if [ "${yn}" == "1" ];
				then
					dialog --title "Rotate Left" \
						--timeout 4 \
						--msgbox "Now writing the following entries to autostart file.\n\n# Rotate screen left.\n@xrandr --output HDMI-1 --rotate left" 0 0
					echo -e "# Rotate screen left\n@xrandr --output HDMI-1 --rotate left" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart > /dev/null
					break
				fi
			fi
		else
			if [ "${yn}" == "1" ];
			then
				dialog --title "Rotate Screen" \
					--clear \
					--msgbox "Leaving screen rotation set to default." 0 0
				break
			fi
		fi
	else
		sudo mv /etc/xdg/lxsession/LXDE-pi/autostart.KioskMMBackup /etc/xdg/lxsession/LXDE-pi/autstart
	fi
done

##########################################################

# Now going to disable the screen saver
while true; do
	_Prev_AutoFile=$(ls /etc/xdg/lxsession/LXDE-pi/ | grep "autostart.screensave")
	if [ "" == "$_Prev_AutoFile" ];
	then
		#Make copy of current autostart file
		sudo cp /etc/xdg/lxsession/LXDE-pi/autostart /etc/xdg/lxsession/LXDE-pi/autostart.screensave
		dialog --title "Screen Saver" \
			--clear \
			--timeout 4 \
			--msgbox "Now going to turn off the screen saver by writing the following entries in the autostart file.\n\n@xset s noblank\n@xset s off\n@xset -dpms" 0 0
		echo -e "@xset s noblank\n@xset s off\n@xset -dpms" | sudo tee -a /etc/xdg/lxsession/LXDE-pi/autostart > /dev/null
		break
	else
		sudo mv /etc/xdg/lxsession/LXDE-pi/autostart.screensave /etc/xdg/lxsession/LXDE-pi/autostart
	fi
done
while true; do
	_Prev_Lightdm=$(ls /etc/lightdm/ | grep "lightdm.conf.original")
	if [ "" == "$_Prev_Lightdm" ];
	then
	#Make backup of original conf
		sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.original
		dialog --title "Screen Saver" \
			--clear \
			--timeout 4 \
			--msgbox "Now going to turn off the screen saver by writing the following entries in the lightdm.conf file.\n\n[SeatDefaults]\nxserver-command=X -x 0 -dpms" 0 0
		echo -e "\n[SeatDefaults]\nxserver-command=X -s 0 -dpms" | sudo tee -a /etc/lightdm/lightdm.conf
		break
	else
		sudo mv /etc/lightdm/lightdm.conf.original /etc/lightdm/lightdm.conf
	fi
done

############################################################

# Now going to connect the MagicMirror Client to your MagicMirror Server

while true; do
	_ServAddr=$(dialog --title "MagicMirror Server Address" \
		--clear \
		--inputbox "Please enter the Address of your running MagicMirror Server below:" 16 52 2>&1 1>&3)
	_InputRes=$?
	case $_InputRes in
		0)
			dialog --title "Server Address" \
				--clear \
				--yesno "You entered $_ServAddr.\nIs this correct?" 0 0
			yn=$?
			if [ "${yn}" == "0" ];
			then
				while true; do
					_Port=$(dialog --title "MagicMirror Server Port" \
						--clear \
						--inputbox "Please enter the Port number of your MagicMirror Server below:" 16 52 2>&1 1>&3)
					_PortRes=$?
					case $_PortRes in
						0)
							dialog --title "Port Number" \
								--clear \
								--yesno "You entered $_Port.\nIs this correct?" 0 0
							yn=$?
							if [ "${yn}" == "0" ];
							then
								dialog --title "Now or Later" \
									--clear \
									--yes-label "Exit" \
									--no-label "Autolaunch" \
									--yesno "You can launch your MagicMirror client by restarting your pi and running 'node clientonly --address "$_ServAddr" -port "$_Port" in your terminal.\nOr you can let me automate the reboot and launch using pm2. Please see https://github.com/MichMich/MagicMirror/wiki/Auto-Starting-MagicMirror for more information on autostarting MagicMirror.\nThank you --JHart" 0 0
								yn=$?
								#######################################################################3
								if [ "${yn}" == "0" ];
								then
									exit
								else
									if [ "${yn}" == "1" ];
									then
										dialog --title "Set Up Automation" \
											--clear \
											--timeout 4 \
											--msgbox "Now going to setup pm2 and needed mm.sh script for auto launch of client after reboot." 0 0
										clear
										sudo npm install -g pm2
										pm2 startup 2>&1 | tee /tmp/pmStart.txt
										sleep 2
										cd
										echo -e "#!/bin/bash\nset -x\n" | tee envScript.sh
										chmod +x envScript.sh
										cat /tmp/pmStart.txt | tee -a envScript.sh
										./envScript.sh

										sleep 4
										rm mm.sh
										sleep 2
										echo -e "cd ~/MagicMirror/\nDISPLAY=:0 node clientonly --address "$_ServAddr" --port "$_Port""  | tee -a mm.sh
										chmod +x mm.sh
										pm2 start mm.sh
										sleep 5
										pm2 save
										sleep 5
										pm2 list
										sleep 5
										sleep2
										rm ./envScript.sh
										sudo reboot
										break
									fi
								fi


								break
							fi;;
						1)
							dialog --title "Oops!" \
								--clear \
								--timeout 2 \
								--msgbox "Unknown error! Killing Script!" 0 0
							exit;;
					esac
				done
				break
			fi;;
			1)
				dialog --title "Oops!" \
					--clear \
					--timeout 2 \
					--msgbox "Unknown error has occured. Bailing out now!" 0 0
				exit;;
		esac
	done
exit
