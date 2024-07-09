#!/bin/bash
softwareVersion=$(git describe --long)

echo -e "\e[1;4;246mRoadApplePi Setup $softwareVersion\e[0m
Welcome to RoadApplePi setup. RoadApplePi is \"Black Box\" software that
can be retrofitted into any car with an OBD port. This software is meant
to be installed on a Raspberry Pi running unmodified Raspbian Stretch,
but it may work on other OSs or along side other programs and modifications.
Use with anything other then out-of-the-box Vanilla Raspbain Stretch is not
supported.

This script will download, compile, and install the necessary dependencies
before finishing installing RoadApplePi itself. Depending on your model of
Raspberry Pi, this may take several hours.
"
#!/bin/bash
if [ $# -ge 1 ]
then
    $answer = $1
else
    #Prompt user if they want to continue
	read -p "Would you like to continue? (y/N) " answer
fi

if [ "$answer" == "n" ] || [ "$answer" == "N" ] || [ "$answer" == "" ]
then
	echo "Setup aborted"
	exit
fi

#################
# Update System #
#################
echo -e "\e[1;4;93mStep 1. Updating system\e[0m"
apt update
apt upgrade -y

###########################################
# Install pre-built dependencies from Apt #
###########################################
echo -e "\e[1;4;93mStep 2. Install pre-built dependencies from Apt\e[0m"
#apt install -y dnsmasq hostapd libbluetooth-dev apache2 php7.3 php7.3-mysql php7.3-bcmath mariadb-server libmariadbclient-dev libmariadbclient-dev-compat uvcdynctrl
apt install -y dnsmasq hostapd libbluetooth-dev apache2 php php-mysql php-bcmath mariadb-server libmariadb-dev uvcdynctrl
systemctl disable hostapd dnsmasq

################
# Install FFMpeg #
################
apt install ffmpeg

#######################
# Install RoadApplePi #
#######################
echo -e "\e[1;4;93mStep 4. Building and installing RoadApplePi\e[0m"
make
make install

cp -r html /var/www/
rm /var/www/html/index.html
chown -R www-data:www-data /var/www/html
chmod -R 0755 /var/www/html
cp raprec.service /lib/systemd/system
chown root:root /lib/systemd/system/raprec.service
chmod 0755 /lib/systemd/system/raprec.service
systemctl daemon-reload
systemctl enable raprec
cp hostapd-rap.conf /etc/hostapd
cp dnsmasq.conf /etc
mkdir /var/www/html/vids
chown -R www-data:www-data /var/www/html

installDate=$(date)
cp roadapplepi.sql roadapplepi-configd.sql
echo "INSERT INTO env (name, value) VALUES (\"rapVersion\", \"$softwareVersion\"), (\"installDate\", \"$installDate\");" >> roadapplepi-configd.sql
mysql < roadapplepi-configd.sql

echo "Done! Please reboot your Raspberry Pi now"
