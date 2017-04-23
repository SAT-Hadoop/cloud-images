#!/bin/bash
yum update -y
yum install -y epel-release
yum install -y cloud-init denyhosts
passwd -l root

# Config denyhosts
sudo service denyhosts start
sudo chkconfig denyhosts on

# installation of collectd

sudo yum install collectd protobuf-c collectd-write_riemann rsyslog


#Copying the provided and configured collectd.d default plugins to be loaded
git clone https://github.com/illinoistech-itm/itmo453-553 /tmp/code
sudo cp -r /tmp/code/collectd/hostb/collectd.d /etc/

#copy the provided collectd.conf file overwritting the default collectd.conf
sudo cp /tmp/code/collectd/hostb/collectd.conf /etc/

# Config rsyslog
# Again assuming that the IP here is the private cloud IP of the Central Rsyslog server
sudo sed -i "$ a *.* @192.168.250.250:514" /etc/rsyslog.conf

#Modify write Riemann plugin
#Modify write Riemann plugin
sudo sed -i '/Host \"riemanna.\example\.com\"/c\Host \"64.131.111.117\"' /etc/collectd.d/write_riemman.conf


sudo systemctl enable collectd
sudo service collectd start


### Configure cloud-init for root
sed -i 's/disable_root:.*/disable_root: 0/g' /etc/cloud/cloud.cfg
sed -i 's/cloud-user/root/g' /etc/cloud/cloud.cfg

cat /etc/cloud/cloud.cfg
