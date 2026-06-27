# Intel Arc Pro B60 – Setup für Ubuntu

Dieses Repository enthält Skripte und Anleitungen zur vollständigen Einrichtung einer
**Intel Arc Pro B60** GPU (Battlemage / Xe2-Architektur) unter Ubuntu.

## Ubuntu-Versionen

| Version | Anleitung |
|---------|-----------|
| Ubuntu 24.04 LTS (Noble Numbat) | [intel-arc-noble.md](intel-arc-noble.md) |
| Ubuntu 26.04 LTS (Resolute Raccoon) | [intel-arc-resolute-raccoon.md](intel-arc-resolute-raccoon.md) |

## Skripte

| Skript | Funktion |
|--------|----------|
| [`drivers.sh`](drivers.sh) | Intel GPU-Repository (Noble/unified Stack) einrichten und Treiber installieren |
| [`neo.sh`](neo.sh) | Intel Compute-Runtime (NEO) manuell von GitHub installieren – für neuere Versionen als im Repo verfügbar |
| [`nvtop.sh`](nvtop.sh) | `nvtop` aus dem Quellcode bauen mit Intel-GPU-Unterstützung |
| [`steam.sh`](steam.sh) | Steam via Flatpak installieren mit eigenem Spieleverzeichnis unter `/data/steam` |

## Was die Anleitungen abdecken

- **Treiber-Installation** – Intel GPU-Repository, GPG-Schlüssel, Paketinstallation (OpenCL, Level Zero, VA-API)
- **Compute-Runtime (NEO)** – Manuelle Installation direkt von GitHub, wenn das Repository veraltet ist
- **GPU-Monitoring** – `nvtop` und `intel_gpu_top` zur Echtzeitüberwachung der GPU-Auslastung
- **Steam / Gaming** – Flatpak-Installation, Proton/Steam Play, Startoptionen für Intel Arc
- **Verifikation** – `clinfo`, `sycl-ls`, `vainfo`, `glxinfo` zur Funktionsprüfung
- **LLM-Inferenz** – Intel `llm-scaler` Framework für LLM-Ausführung auf der B60 via Level Zero/SYCL

## Schnellstart (Ubuntu 24.04)

```bash
# 1. Treiber installieren
chmod +x drivers.sh
./drivers.sh
sudo reboot

# 2. Installation prüfen
clinfo -l

# 3. GPU-Monitoring starten
nvtop
```

## Voraussetzungen

- Ubuntu 24.04 LTS oder 26.04 LTS, 64-Bit
- Intel Arc Pro B60 GPU (PCIe, Battlemage / Xe2)
- Kernel 6.8+ (Ubuntu 24.04: HWE-Kernel empfohlen; Ubuntu 26.04: GA-Kernel ausreichend)
- Benutzer mit `sudo`-Rechten
