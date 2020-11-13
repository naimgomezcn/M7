#!/bin/bash

## en cas de voler detall de què passa realment (màgia oculta)
## docker-compose --verbose -f docker-compose.yml up -d
docker-compose -f docker-compose.yml up -d
sleep 2


#############################
###### dhcpserver      ######
#############################

docker cp 000_dns_resolver.conf dnsresolver:/etc/dnsmasq.d/dhcp.conf
docker exec dnsresolver /bin/bash -c "service dnsmasq restart;service dnsmasq status"
sleep 1 

#############################
###### dhcpserver      ######
#############################

docker cp bindserver01/named.conf.local  dnsserver:/etc/bind/named.conf.local
docker cp bindserver01/named.conf.options dnsserver:/etc/bind/named.conf.options
docker cp bindserver01/zones dnsserver:/etc/bind/zones
docker exec dnsserver /bin/bash -c "service bind9 restart;service bind9 status"
sleep 1 

#############################
###### dhcpclient      ######
#############################


## com de costum, la manera correcta de passar fitxers entre màquina física i contenidor és fer-ho en dos passes:
## 1) copiar (docker cp) el fitxer a un fitxer INEXISTENT del container
## 2) copiar (des de dins del container: docker exec container-name cp) el fitxer que hem copiat abans a la seua posició

#### com que el servidor de dhcp no actua hem de configurar "manualment" el client de dns.
docker cp resolv.conf dhcpclient01:/etc/resolv.conf.estatica
docker exec dhcpclient01 cp /etc/resolv.conf{.estatica,}

docker cp resolv.conf dhcpclient02:/etc/resolv.conf.estatica
docker exec dhcpclient02 cp /etc/resolv.conf{.estatica,}

docker cp resolv.conf dhcpclient03:/etc/resolv.conf.estatica
docker exec dhcpclient03 cp /etc/resolv.conf{.estatica,}

echo "====== fi de la fase de configuració ==========="
docker-compose ps
docker exec dhcpclient01 /bin/sh -c "ping -c 2 dns1.jiznardo.org"
docker exec dhcpclient01 /bin/sh -c "ping -c 2 client01.jiznardo.org"
docker exec dhcpclient01 /bin/sh -c "ping -c 2 client02.jiznardo.org"
docker exec dhcpclient01 /bin/sh -c "dig @72.28.1.100 NS jiznardo.org"
docker exec dhcpclient01 /bin/sh -c "dig @72.28.1.100  client01.jiznardo.org"

echo "====== fi de la fase de validació    ==========="
#
#

