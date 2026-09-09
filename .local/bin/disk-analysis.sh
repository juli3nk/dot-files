#!/usr/bin/env bash
# disk-analysis.sh - Analyse espace disque pour NixOS avec Docker/libvirtd
# Usage: ./disk-analysis.sh

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  ANALYSE ESPACE DISQUE - NixOS"
echo "  $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════════════════════"
echo

# 1. Vue globale
echo "📊 VUE GLOBALE"
echo "───────────────────────────────────────────────────────────"
df -h / /boot 2>/dev/null || df -h /
echo

# 2. Top directories
echo "📁 TOP 15 RÉPERTOIRES (racine)"
echo "───────────────────────────────────────────────────────────"
du -xh --max-depth=2 / 2>/dev/null | sort -hr | head -15 || \
  du -xh / 2>/dev/null | sort -hr | head -15
echo

# 3. NixOS spécifique
echo "🔧 NIXOS / NIX STORE"
echo "───────────────────────────────────────────────────────────"
if command -v nix-du &>/dev/null; then
  echo "→ nix-du disponible:"
  nix-du -qh /nix/store 2>/dev/null | head -10 || echo "  (nix-du n'a rien retourné)"
elif command -v nix-store &>/dev/null; then
  echo "→ Taille /nix/store:"
  du -sh /nix/store 2>/dev/null || echo "  (non accessible)"
  echo "→ Générations:"
  nix-env --list-generations 2>/dev/null | tail -5 || echo "  (nix-env non dispo)"
else
  echo "→ Outils Nix non trouvés"
fi

# Nombre de générations
gen_count=$(ls -d /nix/var/nix/profiles/system-*-link 2>/dev/null | wc -l)
echo "→ Générations système: ~${gen_count}"

# Taille profiles
echo "→ Profiles:"
du -sh /nix/var/nix/profiles 2>/dev/null || echo "  (non accessible)"
echo

# 4. Docker
echo "🐳 DOCKER"
echo "───────────────────────────────────────────────────────────"
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  echo "→ Utilisation globale:"
  docker system df 2>/dev/null || echo "  (docker system df échec)"
  echo
  echo "→ Images (top 10):"
  docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null | head -11 || echo "  (aucune)"
  echo
  echo "→ Containers:"
  docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Size}}" 2>/dev/null | head -11 || echo "  (aucun)"

  # Buildx cache
  if docker buildx du &>/dev/null 2>&1; then
    echo
    echo "→ Buildx cache:"
    docker buildx du 2>/dev/null | head -5 || echo "  (non mesuré)"
  fi

  # Volumes
  echo
  echo "→ Volumes:"
  docker volume ls -q 2>/dev/null | wc -l | xargs -I{} echo "  {} volumes"
  docker system df -v 2>/dev/null | grep -A100 "^VOLUME" | head -10 || true
else
  echo "→ Docker non installé ou daemon non actif"
fi
echo

# 5. Libvirt/QEMU
echo "🖥️  LIBVIRT / QEMU"
echo "───────────────────────────────────────────────────────────"
if command -v virsh &>/dev/null && virsh -c qemu:///system list --all &>/dev/null 2>&1; then
  echo "→ VMs:"
  virsh -c qemu:///system list --all 2>/dev/null || echo "  (aucune)"
  echo
  echo "→ Images VM:"
  if [ -d /var/lib/libvirt/images ]; then
    du -sh /var/lib/libvirt/images 2>/dev/null || echo "  (non accessible)"
    ls -lhS /var/lib/libvirt/images 2>/dev/null | head -10 || true
  else
    echo "  /var/lib/libvirt/images n'existe pas"
  fi
  echo
  echo "→ Pools de stockage:"
  virsh -c qemu:///system pool-list 2>/dev/null || echo "  (aucun)"
else
  echo "→ Libvirt non installé ou daemon non actif"
fi
echo

# 6. Logs et caches
echo "📜 LOGS ET CACHES"
echo "───────────────────────────────────────────────────────────"
echo "→ Journal systemd:"
journalctl --disk-usage 2>/dev/null || echo "  (non mesurable)"
echo
echo "→ Cache utilisateur:"
du -sh ~/.cache 2>/dev/null || echo "  (non accessible)"
echo
echo "→ /var/log:"
du -sh /var/log 2>/dev/null || echo "  (non accessible)"
ls -lhS /var/log 2>/dev/null | head -5 || true
echo

# 7. Autres gros fichiers
echo "📦 FICHIERS > 500MB (hors /nix et /var/lib)"
echo "───────────────────────────────────────────────────────────"
find / -xdev -type f -size +500M 2>/dev/null | head -20 || echo "  (recherche échec)"
echo

# 8. Résumé et recommandations
echo "═══════════════════════════════════════════════════════════"
echo "  RECOMMANDATIONS"
echo "═══════════════════════════════════════════════════════════"
echo

# Nix
if [ "$gen_count" -gt 5 ]; then
  echo "⚠️  NixOS: ${gen_count} générations → envisager nettoyage"
  echo "   → nix-collect-garbage -d  (supprime anciennes générations)"
  echo "   → nix-store --optimize    (dé-duplique liens)"
fi

# Docker
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  dangling=$(docker images -q -f dangling=true 2>/dev/null | wc -l)
  stopped=$(docker ps -a -q -f status=exited 2>/dev/null | wc -l)
  if [ "$dangling" -gt 0 ] || [ "$stopped" -gt 0 ]; then
    echo "⚠️  Docker: ${dangling} images dangling, ${stopped} containers arrêtés"
    echo "   → docker system prune       (nettoyage léger)"
    echo "   → docker system prune -a    (nettoyage agressif)"
    echo "   → docker builder prune      (cache buildx)"
  fi
fi

# Libvirt
if [ -d /var/lib/libvirt/images ]; then
  vm_size=$(du -sm /var/lib/libvirt/images 2>/dev/null | cut -f1)
  if [ "${vm_size:-0}" -gt 10000 ]; then
    echo "⚠️  Libvirt: ${vm_size}MB dans /var/lib/libvirt/images"
    echo "   → virsh list --all          (vérifier VMs inutilisées)"
    echo "   → virsh undefine <vm>       (supprimer VM + disque)"
  fi
fi

# Logs
journal_size=$(journalctl --disk-usage 2>/dev/null | grep -oP '\d+(\.\d+)?[MG]' || echo "")
if [ -n "$journal_size" ]; then
  echo "ℹ️  Journaux: ${journal_size}"
  echo "   → journalctl --vacuum-time=7d  (garder 7 jours)"
fi

echo
echo "═══════════════════════════════════════════════════════════"
echo "  FIN DE L'ANALYSE"
echo "═══════════════════════════════════════════════════════════"
