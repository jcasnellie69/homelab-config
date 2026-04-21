#!/usr/bin/env bash
# Bootstrap an enterprise-ready root automation runtime without storing secrets in git.

set -euo pipefail

DRY_RUN=0
INSTALL_AUTH_KEYS=0
ROOT_HOME="${ROOT_HOME:-/root}"
REPO_DIR_DEFAULT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
REPO_DIR="${REPO_DIR:-${REPO_DIR_DEFAULT}}"

usage() {
  cat <<'EOF'
Usage: bootstrap-root-automation.sh [--dry-run] [--install-authorized-keys] [--root-home PATH] [--repo-dir PATH]

Options:
  --dry-run                Print actions without changing the system.
  --install-authorized-keys  Append repo public keys to authorized_keys if present.
  --root-home PATH         Override the target root home directory (default: /root).
  --repo-dir PATH          Override the repository directory.
EOF
}

log() {
  printf '[bootstrap] %s\n' "$*"
}

run_cmd() {
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

append_if_missing() {
  local source_file="$1"
  local target_file="$2"

  if [[ ! -f "${source_file}" ]]; then
    log "Skipping missing key: ${source_file}"
    return 0
  fi

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    printf '[dry-run] ensure key from %s is present in %s\n' "${source_file}" "${target_file}"
    return 0
  fi

  touch "${target_file}"
  chmod 600 "${target_file}"
  if ! grep -Fqx "$(<"${source_file}")" "${target_file}"; then
    cat "${source_file}" >> "${target_file}"
    printf '\n' >> "${target_file}"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --install-authorized-keys)
      INSTALL_AUTH_KEYS=1
      ;;
    --root-home)
      ROOT_HOME="$2"
      shift
      ;;
    --repo-dir)
      REPO_DIR="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [[ "${DRY_RUN}" -eq 0 && "${EUID}" -ne 0 ]]; then
  printf 'This script must be run as root (or via sudo) unless --dry-run is used.\n' >&2
  exit 1
fi

SSH_DIR="${ROOT_HOME}/.ssh"
CONFIG_DIR="${ROOT_HOME}/.config/homelab"
CACHE_DIR="${ROOT_HOME}/.cache/homelab"
LOG_DIR="${ROOT_HOME}/.local/state/homelab"
RUNTIME_ENV="${CONFIG_DIR}/runtime.env"
KEY_FILE="${SSH_DIR}/id_ed25519"
REPO_LINK="${ROOT_HOME}/homelab-config"

log "Preparing root automation runtime under ${ROOT_HOME}"
run_cmd install -d -m 700 "${SSH_DIR}"
run_cmd install -d -m 755 "${CONFIG_DIR}" "${CACHE_DIR}" "${LOG_DIR}"
run_cmd ln -sfn "${REPO_DIR}" "${REPO_LINK}"

if [[ ! -f "${RUNTIME_ENV}" ]]; then
  if [[ "${DRY_RUN}" -eq 1 ]]; then
    printf '[dry-run] create %s with secret placeholders\n' "${RUNTIME_ENV}"
  else
    cat > "${RUNTIME_ENV}" <<'EOF_ENV'
# Homelab automation runtime environment
# Fill these in locally; do not commit secrets to git.
NETDATA_CLOUD_API_TOKEN=
KLAVIS_STRATA_TOKEN=
NETBOX_URL=http://192.168.4.140/
NETBOX_API_TOKEN=
PVE_API_HOST=192.168.4.10
PVE_API_USER=
PVE_API_TOKEN_ID=
PVE_API_TOKEN_SECRET=
OPNSENSE_BASE_URL=
OPNSENSE_API_KEY=
OPNSENSE_API_SECRET=
GITHUB_TOKEN=
EOF_ENV
    chmod 600 "${RUNTIME_ENV}"
  fi
fi

if [[ ! -f "${KEY_FILE}" ]]; then
  log "Creating root automation SSH key"
  run_cmd ssh-keygen -t ed25519 -N '' -C "homelab-automation@$(hostname)" -f "${KEY_FILE}"
else
  log "Root automation SSH key already present"
fi

if [[ "${INSTALL_AUTH_KEYS}" -eq 1 ]]; then
  log "Installing repo public keys into authorized_keys"
  append_if_missing "${REPO_DIR}/GithubMCP.pub" "${SSH_DIR}/authorized_keys"
  append_if_missing "${REPO_DIR}/Nordpass.pub" "${SSH_DIR}/authorized_keys"
fi

log "Bootstrap complete"
log "Repo link: ${REPO_LINK}"
log "Runtime env: ${RUNTIME_ENV}"
log "SSH key: ${KEY_FILE}"
