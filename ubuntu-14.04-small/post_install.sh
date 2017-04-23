#!/bin/bash
echo password | sudo -S curl -o /etc/rc.local https://raw.githubusercontent.com/viglesiasce/cloud-images/master/utils/rc.local
echo password | sudo -S chmod +x /etc/rc.local

# install latest version of rsyslog
echo password | sudo -S add-apt-repository -y ppa:adiscon/v8-stable
# install Collectd for instances
echo password | sudo -S add-apt-repository -y ppa:collectd/collectd-5.5

echo password | sudo -S apt-get update
echo password | sudo -S apt-get install -y rsyslog collectd 

#Copying the provided and configured collectd.d default plugins to be loaded
git clone https://github.com/illinoistech-itm/itmo453-553 /tmp/code
sudo cp -r /tmp/code/collectd/hosta/collectd.d /etc/

#copy the provided collectd.conf file overwritting the default collectd.conf
sudo cp /tmp/code/collectd/hosta/collectd.conf /etc/collectd/


# Config rsyslog
# Again assuming that the IP here is the private cloud IP of the Central Rsyslog server
sudo sed -i "$ a *.* @192.168.250.250:514" /etc/rsyslog.conf

#Modify write Riemann plugin
sudo sed -i '/Host \"riemanna.\example\.com\"/c\Host \"64.131.111.117\"' /etc/collectd.d/write_riemann.conf

sudo update-rc.d collectd defaults
sudo service collectd start

# Finish modifying for the cloud by stripping the username password via -l
echo "passwd -l vagrant" > /tmp/shutdown
echo "rm /tmp/shutdown" >> /tmp/shutdown
echo "shutdown -P now" >> /tmp/shutdown
