#!/usr/bin/env bash
# wifi-lab.sh — Menu interactif Wi-Fi (Tsurugi/Kali/Ubuntu)
# Légal/éducatif : ne cible que ton propre AP local.
set -euo pipefail

HOTSPOT_NAME="Hotspot"   # nmcli nomme ainsi par défaut
IFACE=""

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "[-] Outil requis manquant: $1"; exit 1; }
}

require ip
require iw
require nmcli

pick_iface() {
  local ifs
  ifs=($(iw dev | awk '/Interface/ {print $2}'))
  if [[ ${#ifs[@]} -eq 0 ]]; then
    echo "[-] Aucune interface Wi-Fi détectée via 'iw dev'."
    exit 1
  fi
  echo "[*] Interfaces Wi-Fi détectées : ${ifs[*]}"
  if [[ ${#ifs[@]} -eq 1 ]]; then
    IFACE="${ifs[0]}"
    echo "[*] Interface sélectionnée: $IFACE"
  else
    echo -n "[?] Choisir l'interface (${ifs[*]}): "
    read -r IFACE
  fi
}

mode_of() {
  iw dev "$1" info 2>/dev/null | awk '/type/ {print $2}'
}

to_monitor() {
  echo "[*] Passage $IFACE -> monitor"
  sudo ip link set "$IFACE" down
  sudo iw dev "$IFACE" set type monitor
  sudo ip link set "$IFACE" up
  echo "[+] Mode: $(mode_of "$IFACE")"
}

to_managed() {
  echo "[*] Passage $IFACE -> managed"
  sudo ip link set "$IFACE" down
  sudo iw dev "$IFACE" set type managed
  sudo ip link set "$IFACE" up
  echo "[+] Mode: $(mode_of "$IFACE")"
}

start_hotspot() {
  # remettre en managed pour que NetworkManager puisse créer l'AP
  [[ "$(mode_of "$IFACE")" != "managed" ]] && to_managed

  echo -n "[?] SSID du Fake AP: "
  read -r SSID
  [[ -z "$SSID" ]] && { echo "[-] SSID vide."; return; }

  echo -n "[?] Mot de passe (>=8 chars): "
  read -r PASS
  [[ ${#PASS} -lt 8 ]] && { echo "[-] Mot de passe trop court."; return; }

  echo "[*] Création du hotspot nmcli…"
  # Si une connexion Hotspot existe déjà, on la down/delete
  sudo nmcli -t -f NAME connection show | grep -Fx "$HOTSPOT_NAME" >/dev/null 2>&1 && {
    sudo nmcli connection down "$HOTSPOT_NAME" || true
    sudo nmcli connection delete "$HOTSPOT_NAME" || true
  }
  sudo nmcli dev wifi hotspot ifname "$IFACE" ssid "$SSID" password "$PASS"
  echo "[+] Hotspot '$SSID' actif sur $IFACE (connexion: $HOTSPOT_NAME)"
}

stop_hotspot() {
  echo "[*] Arrêt du hotspot (si actif)…"
  sudo nmcli connection down "$HOTSPOT_NAME" 2>/dev/null || true
  sudo nmcli connection delete "$HOTSPOT_NAME" 2>/dev/null || true
  echo "[+] Hotspot arrêté/supprimé."
}

show_clients_once() {
  echo "=== Clients associés à $IFACE (iw station dump) ==="
  sudo iw dev "$IFACE" station dump | awk '
    /^Station/ {mac=$2}
    /signal:/ {sig=$2" "$3}
    /tx bitrate:/ {tx=$3" "$4}
    /rx bitrate:/ {rx=$3" "$4; print mac "\tSignal: " sig "\tTX: " tx "\tRX: " rx }'
  echo "=== Connexions NM actives ==="
  nmcli -t -f NAME,TYPE,DEVICE connection show --active || true
}

tail_clients_live() {
  echo "[*] Affichage des clients connectés (Ctrl+C pour arrêter)…"
  while true; do
    clear
    date
    show_clients_once
    sleep 3
  done
}

capture_ap() {
  # capture uniquement le trafic sur l’interface AP (pas d'interception externe)
  require tcpdump
  local pcap="ap_capture_$(date +%Y%m%d_%H%M%S).pcap"
  echo "[*] Capture tcpdump sur $IFACE -> $pcap (Ctrl+C pour arrêter)"
  echo "    Astuce: ouvre une autre console et génère du trafic depuis un device connecté à TON AP."
  sudo tcpdump -i "$IFACE" -w "$pcap"
  echo "[+] Fichier créé: $pcap"
}

scan_wifi() {
  echo "[*] Scan des réseaux (nmcli)…"
  nmcli device wifi rescan || true
  nmcli -f SSID,BSSID,CHAN,SIGNAL,SECURITY device wifi list
}

reset_all() {
  echo "[*] RAZ: arrêt hotspot + managed + NetworkManager reprend la main"
  stop_hotspot
  to_managed
  echo "[+] État final — Mode: $(mode_of "$IFACE")"
}

trap 'echo; echo "[*] Interruption détectée. Pense à lancer l’option 7 (Reset) si besoin."' INT

main_menu() {
  while true; do
    echo
    echo "===== Wi-Fi Lab Menu ($IFACE, mode: $(mode_of "$IFACE")) ====="
    echo "1) Basculer en mode monitor"
    echo "2) Basculer en mode managed (normal)"
    echo "3) Créer/Activer un Fake AP (nmcli hotspot)"
    echo "4) Arrêter/Supprimer le Fake AP"
    echo "5) Voir les clients connectés (live)"
    echo "6) Capturer le trafic AP (tcpdump) — TON AP uniquement"
    echo "7) Reset complet (stop AP + managed)"
    echo "8) Scanner les réseaux environnants"
    echo "9) Quitter"
    echo -n "Choix: "
    read -r c
    case "$c" in
      1) to_monitor ;;
      2) to_managed ;;
      3) start_hotspot ;;
      4) stop_hotspot ;;
      5) tail_clients_live ;;
      6) capture_ap ;;
      7) reset_all ;;
      8) scan_wifi ;;
      9) exit 0 ;;
      *) echo "Choix invalide." ;;
    esac
  done
}

# --- démarrage ---
pick_iface
main_menu
