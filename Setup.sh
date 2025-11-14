#!/usr/bin/env bash
# --------------------------------------------------------------------------------------
# Bluw Setup - Instalação e configuração de Docker, Traefik + Let's Encrypt e Portainer
# Método de execução: bash <(curl -sSL https://raw.githubusercontent.com/ramonsousap/bluew/main/Setup.sh)
# Compatibilidade: Ubuntu 18.04+, 20.04+ | Debian 10+ | CentOS 7+, 8+ (RHEL/Alma/Rocky)
# Funcionalidades essenciais: instalação Docker, Compose, rede proxy, Traefik c/ ACME, Portainer
# Segurança: sem telemetria, logs locais, validação e rollback em falhas críticas
# --------------------------------------------------------------------------------------
set -euo pipefail
declare -A BLUW_TOOLS
bluw_register_tool() { local id="$1"; local name="$2"; local handler="$3"; local version="${4:-}"; local deps="${5:-}"; local config="${6:-}"; BLUW_TOOLS["$id"]="name=$name;handler=$handler;version=$version;deps=$deps;config=$config"; }
bluw_list_tools() { for k in "${!BLUW_TOOLS[@]}"; do echo "$k"; done | sort; }
bluw_get_tool_field() { local id="$1"; local field="$2"; local data="${BLUW_TOOLS[$id]}"; eval "$data"; case "$field" in name) echo "$name";; handler) echo "$handler";; version) echo "$version";; deps) echo "$deps";; config) echo "$config";; esac }
_has() { command -v "$1" >/dev/null 2>&1; }
_docker_ok() { docker info >/dev/null 2>&1; }
_compose_cmd() { if docker compose version >/dev/null 2>&1; then echo "docker compose"; elif _has docker-compose; then echo "docker-compose"; else echo ""; fi; }
_network_exists() { docker network ls --format '{{.Name}}' | grep -q "^$1$"; }
_container_exists() { docker ps -a --format '{{.Names}}' | grep -q "$1"; }
bluw_check_deps() { local id="$1"; local deps; deps=$(bluw_get_tool_field "$id" deps); IFS=',' read -r -a arr <<< "${deps:-}"; for d in "${arr[@]}"; do [ -z "$d" ] && continue; case "$d" in docker) _has docker && _docker_ok || { echo "Docker indisponível"; exit 1; } ;; compose) _compose_cmd >/dev/null || { echo "Compose indisponível"; exit 1; } ;; network:proxy) _network_exists proxy || { echo "Rede proxy ausente"; exit 1; } ;; container:traefik) _container_exists traefik || { echo "Traefik ausente"; exit 1; } ;; container:portainer) _container_exists portainer || { echo "Portainer ausente"; exit 1; } ;; *) : ;; esac; done; }
bluw_run_tool() { local id="$1"; local instance="${2:-}"; local handler; handler=$(bluw_get_tool_field "$id" handler); if [ -z "${handler:-}" ]; then echo "Ferramenta não registrada: $id" >&2; exit 1; fi; if declare -F "$handler" >/dev/null 2>&1; then "$handler" "$instance"; else echo "Handler indisponível: $handler" >&2; exit 1; fi; }
bluw_tool_doc() { local id="$1"; local name version deps config; name=$(bluw_get_tool_field "$id" name); version=$(bluw_get_tool_field "$id" version); deps=$(bluw_get_tool_field "$id" deps); config=$(bluw_get_tool_field "$id" config); echo "id=$id"; echo "name=$name"; echo "version=$version"; echo "deps=$deps"; echo "config=$config"; }
bluw_log() { local event="$1"; local tool="$2"; local message="${3:-}"; local ts; ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ"); local dir="./logs"; mkdir -p "$dir"; printf '{"ts":"%s","event":"%s","tool":"%s","message":"%s"}\n' "$ts" "$event" "$tool" "${message//\"/\' }" >> "$dir"/events.jsonl; }
current_step=""
rollback_needed=false
network_created=false
on_error() { local code=$?; bluw_log "error" "$current_step" "code=$code"; echo "Falha na etapa: $current_step"; if [ "$rollback_needed" = true ]; then rollback; fi; exit "$code"; }
trap on_error ERR
run_step() { current_step="$1"; bluw_log "step_start" "$1" ""; shift; "$@"; bluw_log "step_done" "$current_step" ""; }
ask() { local var="$1"; local msg="$2"; if [ -n "${!var-}" ]; then return 0; fi; if [ -t 0 ]; then read -r -p "$msg" value; else read -r -p "$msg" value < /dev/tty; fi; eval "$var=\"$value\""; }
ensure_network() { if ! _network_exists proxy; then docker network create proxy >/dev/null; network_created=true; fi; }
load_config() { if [ -f setup.env ]; then . setup.env; fi; }
validate_config() { echo "$LETSENCRYPT_EMAIL" | grep -Eq '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' || { echo "Email inválido"; exit 1; } ; echo "$PORTAINER_DOMAIN" | grep -Eq '^[A-Za-z0-9.-]+$' || { echo "Dominio inválido"; exit 1; } ; getent hosts "$PORTAINER_DOMAIN" >/dev/null 2>&1 || true; }
ensure_privileges() { if [ "$(id -u)" -ne 0 ]; then SUDO=sudo; else SUDO=; fi; }
detect_os() { if [ -f /etc/os-release ]; then . /etc/os-release; OS_ID="$ID"; OS_CODENAME="${VERSION_CODENAME:-}"; else echo "Sistema não suportado"; exit 1; fi; case "$OS_ID" in ubuntu|debian) PKG_MGR=apt ;; centos|rhel|almalinux|rocky) PKG_MGR=yum; command -v dnf >/dev/null 2>&1 && PKG_MGR=dnf ;; *) echo "Distribuição não suportada"; exit 1 ;; esac }
install_base() {
  case "$PKG_MGR" in
    apt) $SUDO apt-get update -y >/dev/null; $SUDO apt-get install -y ca-certificates curl gnupg >/dev/null ;;
    yum) $SUDO yum -y install yum-utils ca-certificates curl gnupg2 >/dev/null || true ;;
    dnf) $SUDO dnf -y install dnf-plugins-core ca-certificates curl gnupg2 >/dev/null || true ;;
  esac
}
install_docker() {
  if _has docker && _docker_ok; then return 0; fi
  case "$PKG_MGR" in
    apt)
      $SUDO install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/$OS_ID/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      $SUDO chmod a+r /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_ID $OS_CODENAME stable" | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null
      $SUDO apt-get update -y >/dev/null
      $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null
      ;;
    yum)
      $SUDO yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >/dev/null
      $SUDO yum -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin >/dev/null
      ;;
    dnf)
      $SUDO dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >/dev/null || true
      $SUDO dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin >/dev/null
      ;;
  esac
  $SUDO systemctl enable --now docker
  if [ -n "$SUDO" ]; then $SUDO usermod -aG docker "$USER" || true; fi
}
ensure_compose() {
  if docker compose version >/dev/null 2>&1; then return 0; fi
  if command -v docker-compose >/dev/null 2>&1; then return 0; fi
  local url="https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)"
  $SUDO curl -fsSL "$url" -o /usr/local/bin/docker-compose
  $SUDO chmod +x /usr/local/bin/docker-compose
}
open_ports() { if command -v ufw >/dev/null 2>&1; then if $SUDO ufw status | grep -q active; then $SUDO ufw allow 80/tcp >/dev/null || true; $SUDO ufw allow 443/tcp >/dev/null || true; fi; elif command -v firewall-cmd >/dev/null 2>&1; then $SUDO firewall-cmd --add-service=http --permanent >/dev/null || true; $SUDO firewall-cmd --add-service=https --permanent >/dev/null || true; $SUDO firewall-cmd --reload >/dev/null || true; fi }
prompt_config() { while true; do ask LETSENCRYPT_EMAIL "Email do LetsEncrypt: "; ask PORTAINER_DOMAIN "Dominio do Portainer (ex: portainer.seudominio.com): "; echo "Resumo:"; echo "Email: $LETSENCRYPT_EMAIL"; echo "Dominio: $PORTAINER_DOMAIN"; if [ -t 0 ]; then read -r -p "Confirmar? (Y/N): " c; else read -r -p "Confirmar? (Y/N): " c < /dev/tty; fi; case "$c" in Y|y) break ;; N|n) : ;; *) ;; esac; done }
write_files() { mkdir -p infra/letsencrypt; touch infra/letsencrypt/acme.json; chmod 600 infra/letsencrypt/acme.json || true; printf "LE_EMAIL=%s\nPORTAINER_DOMAIN=%s\n" "$LETSENCRYPT_EMAIL" "$PORTAINER_DOMAIN" > infra/.env; cat > infra/docker-compose.yml <<'YML'
version: "3.8"
services:
  traefik:
    image: traefik:2.11
    command:
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.le.acme.email=${LE_EMAIL}
      - --certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.le.acme.httpchallenge=true
      - --certificatesresolvers.le.acme.httpchallenge.entrypoint=web
      - --api=false
      - --serverstransport.insecureskipverify=false
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./letsencrypt:/letsencrypt
    networks:
      - proxy
    restart: unless-stopped
  portainer:
    image: portainer/portainer-ce:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - portainer_data:/data
    networks:
      - proxy
    restart: unless-stopped
    labels:
      - traefik.enable=true
      - traefik.http.routers.portainer.rule=Host(`${PORTAINER_DOMAIN}`)
      - traefik.http.routers.portainer.entrypoints=websecure
      - traefik.http.routers.portainer.tls.certresolver=le
      - traefik.http.services.portainer.loadbalancer.server.port=9000
      - traefik.http.middlewares.secure.headers.stsSeconds=31536000
      - traefik.http.middlewares.secure.headers.stsIncludeSubdomains=true
      - traefik.http.middlewares.secure.headers.stsPreload=true
      - traefik.http.routers.portainer.middlewares=secure
volumes:
  portainer_data:
networks:
  proxy:
    external: true
YML
}
compose_up() { local cmd; cmd=$(_compose_cmd); (cd infra && $cmd --env-file ./.env up -d); }
wait_container() { local name="$1"; local tries=60; while [ "$tries" -gt 0 ]; do if docker ps --format '{{.Names}}' | grep -q "^$name$"; then return 0; fi; sleep 2; tries=$((tries-1)); done; return 1; }
wait_tls() { local tries=120; while [ "$tries" -gt 0 ]; do if grep -q "$PORTAINER_DOMAIN" infra/letsencrypt/acme.json 2>/dev/null; then return 0; fi; sleep 2; tries=$((tries-1)); done; return 1; }
check_https() { curl -sI --connect-timeout 10 "https://$PORTAINER_DOMAIN" | head -n1 | grep -q "HTTP/"; }
generate_report() { mkdir -p reports; local ts; ts=$(date -u +"%Y%m%dT%H%M%SZ"); local cmd; cmd=$(_compose_cmd); local net; net=$(docker network ls --format '{{.Name}}' | grep -q '^proxy$' && echo true || echo false); local tra; tra=$(docker ps --format '{{.Names}}' | grep -q '^traefik$' && echo true || echo false); local por; por=$(docker ps --format '{{.Names}}' | grep -q '^portainer$' && echo true || echo false); local tls; tls=$(grep -q "$PORTAINER_DOMAIN" infra/letsencrypt/acme.json 2>/dev/null && echo true || echo false); local https; https=$(check_https && echo true || echo false); printf '{"timestamp":"%s","compose_cmd":"%s","email":"%s","domain":"%s","network_proxy":"%s","traefik_running":"%s","portainer_running":"%s","tls_ready":"%s","https_ok":"%s"}\n' "$ts" "$cmd" "$LETSENCRYPT_EMAIL" "$PORTAINER_DOMAIN" "$net" "$tra" "$por" "$tls" "$https" > "reports/infra_report.json"; }
rollback() { echo "Executando rollback..."; local cmd; cmd=$(_compose_cmd); if [ -d infra ]; then (cd infra && $cmd down || true); fi; if [ "$network_created" = true ]; then docker network rm proxy >/dev/null 2>&1 || true; fi }
run_tests() { echo "Iniciando testes"; ensure_privileges; detect_os; install_base; echo "OK base"; install_docker; ensure_compose; echo "OK docker+compose"; LETSENCRYPT_EMAIL="test@example.com" PORTAINER_DOMAIN="portainer.example.com"; validate_config || true; echo "Validação executada"; echo "Testes concluídos"; }
bluw_tool_infra() { load_config; ensure_privileges; detect_os; run_step "install_base" install_base; run_step "install_docker" install_docker; run_step "ensure_compose" ensure_compose; if [ -z "${LETSENCRYPT_EMAIL-}" ] || [ -z "${PORTAINER_DOMAIN-}" ]; then prompt_config; fi; validate_config; run_step "open_ports" open_ports; run_step "ensure_network" ensure_network; rollback_needed=true; run_step "write_files" write_files; run_step "compose_up" compose_up; run_step "wait_traefik" wait_container traefik; run_step "wait_portainer" wait_container portainer; run_step "wait_tls" wait_tls; run_step "report" generate_report; echo "HTTPS em https://$PORTAINER_DOMAIN"; }
bluw_register_tool "infra" "InfraCompose" "bluw_tool_infra" "v1" "docker,compose" '{}'
cmd="${1:-}"
case "$cmd" in
  list) bluw_list_tools ;;
  run) id="${2:-}"; inst="${3:-}"; bluw_log "start" "$id" ""; bluw_run_tool "$id" "$inst"; bluw_log "done" "$id" "" ;;
  info) id="${2:-}"; bluw_tool_doc "$id" ;;
  "") bluw_run_tool infra ;;
  test) run_tests ;;
  *) echo "list|run <id> [inst]|info <id>" ;;
esac
