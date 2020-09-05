# 4L-connect [![FB](http://i.imgur.com/P3YfQoD.png)](https://www.facebook.com/teamconnect4L2021)
4L connecté pour participer au 4L trophy 2021 !


## ⚠️ WORK IN PROGRESS ⚠️

![logo](/imgs/logo-team.png)

# Le projet

Participation au [4L trophy 2021](https://www.4ltrophy.com/).

Nous voulons faire une 4L connecté avec:
- Caméra de recul.
- Phares automatique.
- Acces a plusieurs infos sur ecran (vitesse, essence, batterie, temperature exterieur, temperature moteur, ...).

Le tout sera accessible sur un ecran tactile via une interface web (django).


![voiture](/imgs/voiture-3.jpg)

## Installation
### python
Initialisez un environnement virtuel python3.x
```bash
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

# create database
cd djangoWebsite
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser  # create first user
```

### hotspot mode
```bash
sudo apt install hostapd
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo apt install dnsmasq
sudo DEBIAN_FRONTEND=noninteractive apt install -y netfilter-persistent iptables-persistent
```

```bash
sudo vim /etc/dhcpcd.conf
```
A la fin du fichier, ajouter:
```
interface wlan0
static ip_address=192.168.0.1/24
nohook wpa_supplicant
```

On passe l’étape “Enable routing and IP masquerading” nécessaire seulement pour se connecter à Internet. Ensuite:
```bash
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
```
```bash
sudo vim /etc/dnsmasq.conf
```
Ajouter au fichier:
```
interface=wlan0 # Listening interface
dhcp-range=192.168.0.2,192.168.0.20,255.255.255.0,24h  # Pool of IP addresses served via DHCP
domain=wlan     # Local wireless DNS domain
address=/gw.wlan/192.168.0.1  # Alias for this router
```

```bash
sudo rfkill unblock wlan
```
```bash
sudo vim /etc/hostapd/hostapd.conf
```
Ajouter au fichier:
```
country_code=FR
interface=wlan0
ssid=4L-connect
hw_mode=g
channel=7
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=kirikou78
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```
Note: le mot de passe doit avoir entre 8 et 64 caractères.
Reboot

### reconnect to wifi
Pour réinitialiser la configuration réseau du Raspberry pi (https://raspberrypi.stackexchange.com/questions/72668/how-to-disable-wireless-ap-on-razberry):
```bash
sudo systemctl stop hostapd
sudo vim /etc/dhcpcd.conf
```
Et commenter les dernières lignes
Reboot

## Usage
