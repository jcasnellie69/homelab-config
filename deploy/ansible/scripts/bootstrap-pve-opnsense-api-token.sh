#!/usr/bin/env bash
#-----------------------------------------------------------------------------
# Bootstrap Proxmox API token for OPNsense automation and store it in Semaphore.
#
# Secret handling:
# - The token secret is held in shell variables only.
# - The token secret is not written to Git or artifacts.
# - Script output redacts the token secret.
#-----------------------------------------------------------------------------
set -euo pipefail

PVE_SSH_TARGET="${PVE_SSH_TARGET:-root@192.168.4.10}"
PVE_SSH_KEY="${PVE_SSH_KEY:-}"
PVE_SSH_PROXYJUMP="${PVE_SSH_PROXYJUMP:-}"
PVE_REALM_USER="${PVE_REALM_USER:-ansible@pve}"
PVE_TOKEN_NAME="${PVE_TOKEN_NAME:-opnsense-automation}"
PVE_TOKEN_FULL="${PVE_REALM_USER}!${PVE_TOKEN_NAME}"
PVE_ROLE="${PVE_ROLE:-HomelabOPNsenseAutomation}"
PVE_NODE="${PVE_NODE:-alpha}"
PVE_STORAGES="${PVE_STORAGES:-local local-lvm}"
PVE_VM_PATH="${PVE_VM_PATH:-/vms}"
ROTATE_TOKEN="${ROTATE_TOKEN:-0}"

SEMAPHORE_URL="${SEMAPHORE_URL:-http://127.0.0.1:3000}"
SEMAPHORE_PROJECT_ID="${SEMAPHORE_PROJECT_ID:-1}"
SEMAPHORE_KEY_NAME="${SEMAPHORE_KEY_NAME:-pve-opnsense-api-token}"
SEMAPHORE_COOKIE_FILE="${SEMAPHORE_COOKIE_FILE:-/tmp/semaphore-bootstrap-cookies.txt}"

PVE_ROLE_PRIVS="${PVE_ROLE_PRIVS:-Datastore.AllocateSpace Datastore.Audit Sys.Audit VM.Allocate VM.Audit VM.Config.CDROM VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.PowerMgmt}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 2
  }
}

need ssh
need curl

sem_api() {
  curl -fsS -b "$SEMAPHORE_COOKIE_FILE" -H 'Content-Type: application/json' "$@"
}

sem_login_if_needed() {
  if [[ -f "$SEMAPHORE_COOKIE_FILE" ]] &&
    curl -fsS -b "$SEMAPHORE_COOKIE_FILE" "$SEMAPHORE_URL/api/user" >/dev/null 2>&1; then
    return 0
  fi

  : "${SEMAPHORE_USER:?Set SEMAPHORE_USER or provide a valid SEMAPHORE_COOKIE_FILE}"
  : "${SEMAPHORE_PASSWORD:?Set SEMAPHORE_PASSWORD or provide a valid SEMAPHORE_COOKIE_FILE}"

  curl -fsS -c "$SEMAPHORE_COOKIE_FILE" \
    -H 'Content-Type: application/json' \
    -d "{\"auth\":\"${SEMAPHORE_USER}\",\"password\":\"${SEMAPHORE_PASSWORD}\"}" \
    "$SEMAPHORE_URL/api/auth/login" >/dev/null
}

remote_bootstrap() {
  local remote_script
  local ssh_args=()

  if [[ -n "$PVE_SSH_KEY" ]]; then
    ssh_args+=(-i "$PVE_SSH_KEY")
  fi
  if [[ -n "$PVE_SSH_PROXYJUMP" ]]; then
    ssh_args+=(-J "$PVE_SSH_PROXYJUMP")
  fi

  remote_script="$(cat <<'REMOTE'
set -euo pipefail

user="${PVE_REALM_USER}"
token_name="${PVE_TOKEN_NAME}"
token_full="${PVE_TOKEN_FULL}"
role="${PVE_ROLE}"
privs="${PVE_ROLE_PRIVS}"
vm_path="${PVE_VM_PATH}"
storages="${PVE_STORAGES}"
rotate="${ROTATE_TOKEN}"

if ! pveum user list | awk 'NR>1 {print $2}' | grep -Fxq "$user"; then
  pveum user add "$user" --comment "Ansible OPNsense automation API user"
fi

if pveum role list | awk 'NR>1 {print $1}' | grep -Fxq "$role"; then
  pveum rolemod "$role" -privs "$privs"
else
  pveum roleadd "$role" -privs "$privs"
fi

pveum aclmod "$vm_path" -user "$user" -role "$role"
for storage in $storages; do
  pveum aclmod "/storage/${storage}" -user "$user" -role "$role"
done

if pveum user token list "$user" | awk 'NR>1 {print $1}' | grep -Fxq "$token_name"; then
  if [[ "$rotate" == "1" ]]; then
    pveum user token remove "$user" "$token_name"
  else
    echo "TOKEN_EXISTS"
    exit 20
  fi
fi

token_json="$(pveum user token add "$user" "$token_name" --privsep 1 --output-format json)"
token_secret="$(printf '%s' "$token_json" | sed -n 's/.*"value"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

if [[ -z "$token_secret" ]]; then
  echo "TOKEN_PARSE_FAILED"
  exit 21
fi

pveum aclmod "$vm_path" -token "$token_full" -role "$role"
for storage in $storages; do
  pveum aclmod "/storage/${storage}" -token "$token_full" -role "$role"
done

printf 'TOKEN_SECRET=%s\n' "$token_secret"
REMOTE
)"

  ssh "${ssh_args[@]}" -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$PVE_SSH_TARGET" \
    "PVE_REALM_USER='$PVE_REALM_USER' PVE_TOKEN_NAME='$PVE_TOKEN_NAME' PVE_TOKEN_FULL='$PVE_TOKEN_FULL' PVE_ROLE='$PVE_ROLE' PVE_ROLE_PRIVS='$PVE_ROLE_PRIVS' PVE_VM_PATH='$PVE_VM_PATH' PVE_STORAGES='$PVE_STORAGES' ROTATE_TOKEN='$ROTATE_TOKEN' bash -s" \
    <<<"$remote_script"
}

create_or_update_semaphore_key() {
  local token_secret="$1"
  local keys key_id payload

  keys="$(sem_api "$SEMAPHORE_URL/api/project/${SEMAPHORE_PROJECT_ID}/keys")"
  key_id="$(printf '%s' "$keys" | sed -n "s/.*{\"id\":\\([0-9][0-9]*\\),\"name\":\"${SEMAPHORE_KEY_NAME}\".*/\\1/p" | head -n1)"

  payload="$(
    printf '{"name":"%s","type":"login_password","project_id":%s,"login_password":{"login":"%s","password":"%s"}}' \
      "$SEMAPHORE_KEY_NAME" "$SEMAPHORE_PROJECT_ID" "$PVE_TOKEN_FULL" "$token_secret"
  )"

  if [[ -n "$key_id" ]]; then
    sem_api -X PUT -d "$payload" "$SEMAPHORE_URL/api/project/${SEMAPHORE_PROJECT_ID}/keys/${key_id}" >/dev/null
    echo "Updated Semaphore key: ${SEMAPHORE_KEY_NAME} (id ${key_id})"
  else
    sem_api -X POST -d "$payload" "$SEMAPHORE_URL/api/project/${SEMAPHORE_PROJECT_ID}/keys" >/dev/null
    echo "Created Semaphore key: ${SEMAPHORE_KEY_NAME}"
  fi
}

validate_proxmox_api() {
  local token_secret="$1"
  curl -fsSk \
    -H "Authorization: PVEAPIToken=${PVE_TOKEN_FULL}=${token_secret}" \
    "https://${PVE_API_HOST:-192.168.4.10}:8006/api2/json/version" >/dev/null
  echo "Validated authenticated Proxmox API version discovery with ${PVE_TOKEN_FULL}"
}

main() {
  sem_login_if_needed

  echo "Bootstrapping Proxmox API user/token on ${PVE_SSH_TARGET}"
  bootstrap_output="$(remote_bootstrap)" || {
    rc=$?
    if [[ "$rc" == "20" ]]; then
      echo "Token ${PVE_TOKEN_FULL} already exists. Set ROTATE_TOKEN=1 to rotate it." >&2
    else
      echo "Remote bootstrap failed with rc=${rc}" >&2
    fi
    exit "$rc"
  }

  token_secret="$(printf '%s\n' "$bootstrap_output" | sed -n 's/^TOKEN_SECRET=//p' | tail -n1)"
  if [[ -z "$token_secret" ]]; then
    echo "Token secret was not captured from pveum output." >&2
    exit 3
  fi

  create_or_update_semaphore_key "$token_secret"
  validate_proxmox_api "$token_secret"
  echo "Bootstrap complete. Token secret was not printed."
}

main "$@"
