#!/bin/bash
echo password | sudo -S curl -o /etc/rc.local https://raw.githubusercontent.com/viglesiasce/cloud-images/master/utils/rc.local
echo password | sudo -S chmod +x /etc/rc.local

# install latest version of rsyslog
echo password | sudo -S add-apt-repository -y ppa:adiscon/v8-stable
# install Collectd for instances
echo password | sudo -S add-apt-repository ppa:collectd/collectd-5.5

echo password | sudo -S apt-get update
echo password | sudo -S sudo apt-get install -y rsyslog collectd 

#Copying the provided and configured collectd.d default plugins to be loaded
git clone https://github.com/illinoistech-itm/itmo453-553 /tmp/code
sudo cp -r /tmp/code/collectd/hosta/collectd.d /etc/

#copy the provided collectd.conf file overwritting the default collectd.conf
sudo cp /tmp/code/collectd/hosta/collectd.conf /etc/collectd/

sudo update-rc.d collectd defaults
sudo service collectd start

# Config rsyslog
# Again assuming that the IP here is the private cloud IP of the Central Rsyslog server
sudo sed -i "$ a *.* @192.168.250.250:514" /etc/rsyslog.conf

#Modify write Riemann plugin
sudo cat << EOT >> /etc/collectd.d/write_riemman.conf
LoadPlugin write_riemann
<Plugin "write_riemann">
    <Node "riemanna">
        Host "192.168.250.251"
        Port "5555"
        Protocol TCP
        StoreRates false
        CheckThresholds true
        TTLFactor 30.0
    </Node>
    Tag "collectd"
</Plugin>
EOT

# Finish modifying for the cloud by stripping the username password via -l
echo "passwd -l vagrant" > /tmp/shutdown
echo "rm /tmp/shutdown" >> /tmp/shutdown
echo "shutdown -P now" >> /tmp/shutdown
