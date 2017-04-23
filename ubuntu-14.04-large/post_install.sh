#!/bin/bash
echo password | sudo -S curl -o /etc/rc.local https://raw.githubusercontent.com/viglesiasce/cloud-images/master/utils/rc.local
echo password | sudo -S chmod +x /etc/rc.local

# install latest version of rsyslog
echo password | sudo -S add-apt-repository -y ppa:adiscon/v8-stable

echo password | sudo -S  apt-get update
sudo apt-get install -y rsyslog

# install Collectd for instances
sudo sudo add-apt-repository ppa:collectd/collectd-5.5

sudo apt-get update
sudo apt-get -y install collectd 

#Copying the provided and configured collectd.d default plugins to be loaded
git clone https://github.com/illinoistech-itm/itmo453-553 /tmp/code
sudo cp -r /tmp/code/itmo453-553/collectd/hosta/collectd.d /etc/

#copy the provided collectd.conf file overwritting the default collectd.conf
sudo cp /tmp/code/itmo453-553/collectd/hosta/collectd.conf /etc/collectd/


sudo update-rc.d collectd defaults
sudo service collectd start

# Config rsyslog
# Again assuming that the IP here is the private cloud IP of the Central Rsyslog server
sudo sed -i "$ a *.* @192.168.250.250:514" /etc/rsyslog.conf


# Finish modifying for the cloud by stripping the username password via -l
echo "passwd -l vagrant" > /tmp/shutdown
echo "rm /tmp/shutdown" >> /tmp/shutdown
echo "shutdown -P now" >> /tmp/shutdown
