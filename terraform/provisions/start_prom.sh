#!/usr/bin/env bash
#

#Attach storage: If we decide to make the storage persistent
#sudo mkfs -t ext4 /dev/xvdf #Remove this if for some reason we suspect we might need to use this script on a previous drive (ex. a snapshot)
sudo mkdir -m 777 /data
# add the device on every reboot
#echo "/dev/xvdf /data ext3 defaults,nofail 0 2" | sudo tee -a /etc/fstab
#sudo mount -a

REPLACEMENTS_DIR='/tmp/prometheus/config_prometheus'
PROM_CONFIG='/prometheus.yml'
PROM_ALERT='/alert.rules'

if [ -f ${REPLACEMENTS_DIR}${PROM_CONFIG} ]
  then
    cp ${REPLACEMENTS_DIR}${PROM_CONFIG} /etc/prometheus/prometheus.yml
    echo 'Using ${PROM_CONFIG} from ${REPLACEMENTS_DIR}${PROM_CONFIG}'
fi

if [ -f ${REPLACEMENTS_DIR}${PROM_ALERT} ]
  then
    cp ${REPLACEMENTS_DIR}${PROM_ALERT} /etc/prometheus/alert.rules
    echo 'Using ${PROM_ALERT} from ${REPLACEMENTS_DIR}${PROM_ALERT}'
fi

#Start Prometheus
sudo $(pwd)/docker-compose up -d