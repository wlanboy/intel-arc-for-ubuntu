#!/bin/bash

# Ubuntu-Codename ermitteln
UBUNTU_CODENAME=$(. /etc/os-release 2>/dev/null && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
if [ -z "$UBUNTU_CODENAME" ]; then
    UBUNTU_CODENAME=$(lsb_release -cs 2>/dev/null)
fi
if [ -z "$UBUNTU_CODENAME" ]; then
    echo "FEHLER: Ubuntu-Version konnte nicht ermittelt werden." >&2
    exit 1
fi

echo "Erkannte Ubuntu-Version: $UBUNTU_CODENAME"

# 1. Alte/fehlerhafte Repositories entfernen
sudo rm -f /etc/apt/sources.list.d/intel-graphics.list
sudo rm -f /etc/apt/sources.list.d/intel-gpu-noble.list
sudo rm -f /etc/apt/sources.list.d/intel-gpu-resolute-raccoon.list

# 2. GPG-Schlüssel korrekt importieren
sudo mkdir -p /usr/share/keyrings
wget -qO - https://repositories.intel.com/gpu/intel-graphics.key | \
    sudo gpg --dearmor --yes --output /usr/share/keyrings/intel-graphics.gpg
sudo chmod 644 /usr/share/keyrings/intel-graphics.gpg

# 3. Intel GPU Repository einrichten
INTEL_REPO_BASE="https://repositories.intel.com/gpu/ubuntu"
LIST_FILE="/etc/apt/sources.list.d/intel-gpu-${UBUNTU_CODENAME}.list"

case "$UBUNTU_CODENAME" in
    noble)
        REPO_CODENAME="noble"
        ;;
    resolute-raccoon)
        # Prüfen ob Intel bereits einen nativen Stack für Resolute Raccoon bereitstellt
        CHECK_URL="${INTEL_REPO_BASE}/dists/resolute-raccoon/unified/binary-amd64/Packages"
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$CHECK_URL" 2>/dev/null || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
            echo "Resolute-Raccoon-Repository gefunden – verwende nativen Stack."
            REPO_CODENAME="resolute-raccoon"
        else
            echo "Kein Resolute-Raccoon-Repository verfügbar (HTTP $HTTP_CODE) – Fallback auf Noble-Stack (ABI-kompatibel)."
            REPO_CODENAME="noble"
        fi
        ;;
    *)
        echo "WARNUNG: Unbekannte Ubuntu-Version '$UBUNTU_CODENAME' – versuche Noble-Stack als Fallback."
        REPO_CODENAME="noble"
        ;;
esac

echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] ${INTEL_REPO_BASE} ${REPO_CODENAME} unified" | \
    sudo tee "$LIST_FILE"

# 4. OneAPI Repository hinzufügen
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
    gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
    sudo tee /etc/apt/sources.list.d/oneAPI.list

# 5. System-Update
sudo apt update

# 6. Installation der Treiber-Komponenten
sudo apt install -y \
    intel-opencl-icd \
    libze-intel-gpu1 \
    libze1 \
    intel-media-va-driver-non-free \
    libigdgmm12 \
    clinfo \
    intel-gpu-tools \
    mesa-utils

# 7. Installation der OneAPI Entwicklungstools (optional, für KI/ML/SYCL)
sudo apt install -y intel-oneapi-compiler-dpcpp-cpp intel-oneapi-mkl

# 8. Benutzer zur Gruppe 'render' hinzufügen (Wichtig für Zugriff ohne sudo)
sudo usermod -aG render $USER
sudo usermod -aG video $USER

echo "-----------------------------------------------------------"
echo "Installation abgeschlossen!"
echo "  Ubuntu:    $UBUNTU_CODENAME"
echo "  Intel-Repo: $REPO_CODENAME"
echo "WICHTIG: Starte deinen PC neu, damit alle Änderungen greifen."
echo "Nach dem Neustart kannst du mit 'clinfo -l' testen."
echo "-----------------------------------------------------------"
#source /opt/intel/oneapi/setvars.sh
#sycl-ls
