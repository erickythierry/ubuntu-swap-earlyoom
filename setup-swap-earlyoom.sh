#!/usr/bin/env bash
# Script para Ubuntu Server: ativa swap e configura earlyoom
# Uso: sudo bash setup-swap-earlyoom.sh
# Tamanho do swap (opcional): SWAP_SIZE=4G sudo bash setup-swap-earlyoom.sh

set -e

SWAP_SIZE="${SWAP_SIZE:-8G}"
SWAPFILE="/swapfile"

if [[ $EUID -ne 0 ]]; then
  echo "Execute como root: sudo bash $0"
  exit 1
fi

echo "=== Configurando swap (${SWAP_SIZE}) e earlyoom ==="

# --- Swap ---
if [[ ! -f "$SWAPFILE" ]]; then
  echo "[1/5] Criando arquivo de swap..."
  fallocate -l "$SWAP_SIZE" "$SWAPFILE"
  chmod 600 "$SWAPFILE"
  mkswap "$SWAPFILE"
  swapon "$SWAPFILE"
  echo "Swap ativado."
else
  echo "[1/5] $SWAPFILE já existe. Ativando se necessário..."
  if ! swapon --show | grep -q "$SWAPFILE"; then
    swapon "$SWAPFILE"
  fi
fi

# --- Persistir swap no fstab ---
if ! grep -q '/swapfile none swap' /etc/fstab; then
  echo "[2/5] Adicionando swap ao /etc/fstab..."
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
else
  echo "[2/5] Swap já está no /etc/fstab."
fi

# --- Swappiness ---
echo "[3/5] Ajustando vm.swappiness=10..."
sysctl vm.swappiness=10
if ! grep -q 'vm.swappiness=10' /etc/sysctl.conf; then
  echo 'vm.swappiness=10' >> /etc/sysctl.conf
fi

# --- Early OOM ---
echo "[4/5] Instalando earlyoom..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y earlyoom

echo "[5/5] Habilitando e iniciando earlyoom..."
systemctl enable earlyoom
systemctl start earlyoom

echo ""
echo "=== Concluído ==="
echo "Swap: $(swapon --show)"
echo "earlyoom: $(systemctl is-active earlyoom)"
echo "vm.swappiness: $(sysctl -n vm.swappiness)"
