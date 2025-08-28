# trkn-wifi-ap
Educative: create a fake wifi ap and intercept connection.. . Only educative. By trhacknon

```bash
chmod +x fakeap.sh
sudo ./fakeap.sh
```

# Ressources Wi-Fi offensives (GitHub - trh4ckn0n)

Ce document présente et décrit plusieurs **outils open-source regroupés par trh4ckn0n**, souvent utilisés pour des tests offensifs Wi-Fi (Evil-Twin, phishing, captures de handshake), à des fins pédagogiques ou d’audit.

---

## 1. [fluxion](https://github.com/trh4ckn0n/fluxion)

Fluxion est une réécriture améliorée de **Linset**, un outil de phishing Wi-Fi. Il automatise le vol de clés WPA/WPA2 via un **Evil-Twin + captive portal**, en combinant capture de handshake et technique d’ingénierie sociale.  
- Deux modes principaux : **Handshake Snooper** (capture passive ou avec deauth) et **Captive Portal** (AP factice + page de phishing)  
- Supporte injection, DNS redirection, gestion de handshake, portails personnalisables  
0

---

## 2. [FluxER](https://github.com/trh4ckn0n/FluxER)

**FluxER** est un script Bash permettant d’installer et lancer *Fluxion* dans un environnement **Termux** (Android).  
Permet aux testeurs d’exécuter rapidement des attaques sur smartphone, hors PC classique.  
1

---

## 3. [Hacke-WiFi](https://github.com/trh4ckn0n/Hacke-WiFi)

Un script shell qui combine plusieurs outils préinstallés dans Kali Linux pour attaquer différents types de réseaux (WEP, WPS, WPA, WPA2). Plutôt orienté **brute force / cracking**, automatisant l’usage d’outils classiques.  
2

---

## 4. [wifiphisher](https://github.com/trh4ckn0n/wifiphisher)

Framework complet pour des attaques phishing Wi-Fi.  
- Gère l’Evil-Twin, le **KARMA attack**, le **Known Beacons**, et captive portals personnalisés.  
- Déauthentication des clients, création de pont AP + DHCP, serveur web intégré pour phishing.  
- Extensible via modules Python et templates communautaires.  
3

---

## 5. [extra-phishing-pages](https://github.com/trh4ckn0n/extra-phishing-pages)

Recueil de **scénarios/interfaces HTML supplémentaires** pour **Wifiphisher**. Permet d’ajouter des pages de phishing plus convaincantes ou thématisées (ex. captive portal personnalisés).  
4

---

##  Tableau résumé

| Outil                | Fonction principale                                     | Usage typique                     |
|---------------------|----------------------------------------------------------|-----------------------------------|
| **Fluxion**         | Evil-Twin + captive portal + handshake capture          | Phishing WPA générale             |
| **FluxER**          | Wrapper de Fluxion sur Android via Termux               | Mobilité / démonstration mobile   |
| **Hacke-WiFi**      | Cracking (WEP/WPA/WPS) via outils Kali                  | Cracking automatisé               |
| **Wifiphisher**     | Evil-Twin + phishing avec modules/KARMA/Known Beacons   | Red Team / phishing Wi-Fi avancé  |
| **extra-phishing-pages** | Templates HTML pour Wifiphisher                  | Customisation des portails        |

---

##  Pourquoi comprendre ces outils est utile en blue team

- **Fluxion** et **Wifiphisher** utilisent des mécanismes clairs : déauth, AP factice, phishing. Surveiller :
  - AP avec même SSID, BSSID différent  
  - Augmentation anormale des frames deauth  
  - Nouveaux portails captive dans un réseau non prévu

- **FluxER** indique une attaque effectuée via un smartphone — penser à surveiller les AP provenant de clients mobiles.

- **Hacke-WiFi** montre qu’une simple machine peut lancer plusieurs types d’attaques simultanément : surveiller les bruteforces sur différents protocoles.

- **Template phishing** (extra-phishing-pages) : vigilance contre les portails suspects (formulaires personnalisés, redirections).

---

> **Remarque légale / éthique** : l’usage de ces outils sur des réseaux sans consentement est illégal. Ils sont destinés à des environnements contrôlés (audit pentest, lab, formation).  
