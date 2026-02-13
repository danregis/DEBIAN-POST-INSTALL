#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_NAME="$(basename "$0")"
UPDATE_HELPER="/usr/local/bin/update-system"

log() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

die() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

on_error() {
  local line="$1"
  die "Command failed at line ${line}."
}

trap 'on_error $LINENO' ERR

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    die "Run this script as root (for example: sudo ./${SCRIPT_NAME})."
  fi
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: ${cmd}"
}

confirm() {
  local prompt="$1"
  local answer
  read -r -p "${prompt} [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

detect_os() {
  [[ -r /etc/os-release ]] || die "/etc/os-release is missing."
  # shellcheck disable=SC1091
  . /etc/os-release

  DISTRO_ID="${ID:-unknown}"
  DISTRO_VERSION_ID="${VERSION_ID:-unknown}"
  DISTRO_CODENAME="${VERSION_CODENAME:-}"

  if [[ -z "${DISTRO_CODENAME}" ]] && command -v lsb_release >/dev/null 2>&1; then
    DISTRO_CODENAME="$(lsb_release -sc)"
  fi

  if [[ -z "${DISTRO_CODENAME}" ]]; then
    die "Could not detect distro codename."
  fi

  log "Detected ${DISTRO_ID} ${DISTRO_VERSION_ID} (${DISTRO_CODENAME})."
}

apt_update() {
  DEBIAN_FRONTEND=noninteractive apt-get update
}

apt_upgrade() {
  DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y
}

apt_install() {
  if [[ "$#" -eq 0 ]]; then
    return 0
  fi
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

install_first_available() {
  local pkg
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      apt_install "$pkg"
      return 0
    fi
  done
  warn "None of these packages were available: $*"
  return 1
}

backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local backup="${file}.bak.$(date +%Y%m%d-%H%M%S)"
    cp -a "$file" "$backup"
    log "Backed up ${file} -> ${backup}"
  fi
}

add_repo() {
  detect_os
  if [[ "${DISTRO_ID}" != "debian" ]]; then
    die "This repo setup only supports Debian. Detected: ${DISTRO_ID}."
  fi

  backup_file "/etc/apt/sources.list"

  cat >/etc/apt/sources.list <<EOF
# Managed by ${SCRIPT_NAME}
deb http://deb.debian.org/debian ${DISTRO_CODENAME} main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian ${DISTRO_CODENAME} main contrib non-free non-free-firmware

deb http://deb.debian.org/debian ${DISTRO_CODENAME}-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian ${DISTRO_CODENAME}-updates main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security ${DISTRO_CODENAME}-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security ${DISTRO_CODENAME}-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian ${DISTRO_CODENAME}-backports main contrib non-free non-free-firmware
EOF

  apt_update
  log "Debian repositories updated for ${DISTRO_CODENAME}."
}

create_update_helper() {
  cat >"${UPDATE_HELPER}" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get full-upgrade -y
apt-get autoremove -y
apt-get autoclean -y
EOF
  chmod 0755 "${UPDATE_HELPER}"
  log "Created update helper at ${UPDATE_HELPER}."
}

update_system() {
  apt_update
  apt_upgrade
  DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
  DEBIAN_FRONTEND=noninteractive apt-get autoclean -y
  log "System update completed."
}

firmware() {
  detect_os
  if [[ "${DISTRO_ID}" != "debian" ]]; then
    warn "Firmware list is tuned for Debian and may be partial on ${DISTRO_ID}."
  fi

  apt_install firmware-linux firmware-misc-nonfree iucode-tool

  if grep -qi intel /proc/cpuinfo; then
    apt_install intel-microcode
  elif grep -qi amd /proc/cpuinfo; then
    apt_install amd64-microcode
  else
    warn "Unknown CPU vendor; skipping microcode package selection."
  fi

  apt_install fonts-crosextra-carlito fonts-crosextra-caladea
  apt_install rar unrar ffmpeg gstreamer1.0-libav gstreamer1.0-plugins-ugly gstreamer1.0-vaapi
}

cli_install() {
  apt_install build-essential cmake git tmux nano curl wget rsync htop lshw pciutils usbutils
  apt_install unzip zip p7zip-full
  install_first_available fd-find fd || true
  install_first_available ripgrep rg || true
  install_first_available speedtest-cli || true
  apt_install net-tools dnsutils traceroute
}

gui_install() {
  apt_install gparted gvfs-backends ntfs-3g xarchiver galculator vlc mpv
  apt_install blender imagemagick inkscape gimp audacity filezilla libreoffice
  apt_install firefox-esr
  install_first_available openshot-qt openshot || true
}

install_vscode_repo() {
  require_cmd curl
  require_cmd gpg

  apt_install ca-certificates curl gpg
  install -d -m 0755 /etc/apt/keyrings

  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
  chmod 0644 /etc/apt/keyrings/microsoft.gpg

  cat >/etc/apt/sources.list.d/vscode.list <<'EOF'
deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main
EOF

  apt_update
  apt_install code
}

gpu_drivers() {
  require_cmd lspci

  local gpu_info
  gpu_info="$(lspci -nn | grep -Ei 'vga|3d|display' || true)"

  if echo "$gpu_info" | grep -qi nvidia; then
    log "NVIDIA GPU detected. Installing Debian-packaged NVIDIA driver."
    apt_install nvidia-driver firmware-misc-nonfree
  elif echo "$gpu_info" | grep -qi amd; then
    log "AMD GPU detected. Installing open-source AMD graphics stack."
    apt_install firmware-amd-graphics mesa-vulkan-drivers mesa-va-drivers
  elif echo "$gpu_info" | grep -Eqi 'intel|arc'; then
    log "Intel GPU detected. Installing Intel media and Vulkan stack."
    apt_install intel-media-va-driver-non-free mesa-vulkan-drivers
  else
    warn "No supported GPU vendor detected automatically."
  fi
}

firewall() {
  apt_install ufw
  ufw --force enable
  systemctl enable --now ufw
  if systemctl is-enabled --quiet ssh || systemctl is-enabled --quiet sshd; then
    ufw allow OpenSSH || true
  fi
  log "Firewall enabled with UFW."
}

laptop() {
  apt_install tlp
  systemctl enable --now tlp
  log "TLP enabled."
}

tweaks() {
  cat >/etc/sysctl.d/99-postinstall.conf <<'EOF'
# Managed by debian-post-install.sh
vm.swappiness=10
EOF
  sysctl --system >/dev/null
  log "Applied swappiness tweak (vm.swappiness=10)."
}

menu() {
  local options=(
    "Add_Repo"
    "Update_System"
    "Create_Update_Helper"
    "Firmware"
    "CLI_Soft"
    "GUI_Soft"
    "Install_VSCode"
    "GPU_Drivers"
    "Firewall"
    "Laptop"
    "Tweaks"
    "All_Common"
    "Quit"
  )

  PS3='Make your selection: '
  select selection in "${options[@]}"; do
    case "$selection" in
      "Add_Repo")
        confirm "Replace /etc/apt/sources.list with detected Debian ${DISTRO_CODENAME:-<auto>} repos?" && add_repo
        ;;
      "Update_System")
        confirm "Run full system update now?" && update_system
        ;;
      "Create_Update_Helper")
        confirm "Create ${UPDATE_HELPER}?" && create_update_helper
        ;;
      "Firmware")
        confirm "Install firmware and microcode packages?" && firmware
        ;;
      "CLI_Soft")
        confirm "Install CLI packages?" && cli_install
        ;;
      "GUI_Soft")
        confirm "Install GUI packages?" && gui_install
        ;;
      "Install_VSCode")
        confirm "Add Microsoft repo and install VS Code?" && install_vscode_repo
        ;;
      "GPU_Drivers")
        confirm "Auto-detect GPU and install matching drivers?" && gpu_drivers
        ;;
      "Firewall")
        confirm "Install and enable UFW firewall?" && firewall
        ;;
      "Laptop")
        confirm "Install and enable TLP?" && laptop
        ;;
      "Tweaks")
        confirm "Apply sysctl tweaks?" && tweaks
        ;;
      "All_Common")
        if confirm "Run common baseline steps (update, firmware, CLI, GUI, firewall, laptop, tweaks)?"; then
          update_system
          firmware
          cli_install
          gui_install
          firewall
          laptop
          tweaks
        fi
        ;;
      "Quit")
        exit 0
        ;;
      *)
        warn "Invalid option."
        ;;
    esac
  done
}

main() {
  require_root
  detect_os

  case "${1:-menu}" in
    add_repo) add_repo ;;
    update) update_system ;;
    helper) create_update_helper ;;
    firmware) firmware ;;
    cli) cli_install ;;
    gui) gui_install ;;
    vscode) install_vscode_repo ;;
    gpu) gpu_drivers ;;
    firewall) firewall ;;
    laptop) laptop ;;
    tweaks) tweaks ;;
    all)
      update_system
      firmware
      cli_install
      gui_install
      firewall
      laptop
      tweaks
      ;;
    menu) menu ;;
    *)
      cat <<EOF
Usage: ${SCRIPT_NAME} [command]

Commands:
  menu       Show interactive menu (default)
  add_repo   Replace Debian sources.list for detected codename
  update     Run apt update + full-upgrade + cleanup
  helper     Create ${UPDATE_HELPER}
  firmware   Install firmware/microcode/media packages
  cli        Install CLI package set
  gui        Install GUI package set
  vscode     Add Microsoft repo and install VS Code
  gpu        Auto-install GPU drivers by detected vendor
  firewall   Install and enable ufw
  laptop     Install and enable tlp
  tweaks     Apply sysctl tweaks
  all        Run common baseline steps
EOF
      exit 1
      ;;
  esac
}

main "$@"
