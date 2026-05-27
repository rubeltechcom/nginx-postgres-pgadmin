#!/bin/bash
# ================================================
#  Nginx + PostgreSQL + pgAdmin 4 Auto Installer
#  Supports: Ubuntu 20.04, 22.04, 24.04 / Debian
#  GitHub: https://github.com/rubeltechcom/nginx-postgres-pgadmin
# ================================================

set -e

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; BLUE='\033[0;34m'
BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
section() { echo -e "\n${BLUE}${BOLD}━━━ $1 ━━━${NC}"; }

# ── Root check ──
if [[ $EUID -ne 0 ]]; then
  error "Please run as root: sudo ./install.sh"
fi

# ── OS check ──
if ! command -v apt &>/dev/null; then
  error "This script only supports Ubuntu/Debian (apt-based systems)"
fi

# ================================================
# CONFIGURATION — এখানে আপনার তথ্য দিন
# ================================================

clear
echo -e "${BOLD}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║   Nginx + PostgreSQL + pgAdmin 4      ║"
echo "  ║   Auto Installer for Ubuntu/Debian    ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"

prompt_for_value() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="$3"
    
    if [[ -n "${!var_name}" ]]; then
        return
    fi
    
    local user_input
    if [[ -c /dev/tty ]]; then
        read -rp "  ${YELLOW}$prompt_text${NC} [$default_value]: " user_input < /dev/tty
    else
        read -rp "  ${YELLOW}$prompt_text${NC} [$default_value]: " user_input
    fi
    
    if [[ -z "$user_input" ]]; then
        eval "$var_name=\"$default_value\""
    else
        eval "$var_name=\"$user_input\""
    fi
}

echo -e "  Please configure the installation (Press ENTER to use defaults):"
prompt_for_value PG_PASSWORD "PostgreSQL Password" "StrongPass@1234"
prompt_for_value PGADMIN_EMAIL "pgAdmin Email" "admin@local.com"
prompt_for_value PGADMIN_PASSWORD "pgAdmin Password" "Admin@1234"
prompt_for_value PGADMIN_PORT "pgAdmin Port" "5050"
prompt_for_value NGINX_PORT "Nginx Port" "80"
# ================================================

echo ""
echo -e "  ${GREEN}Summary:${NC}"
echo -e "  PostgreSQL Password : $PG_PASSWORD"
echo -e "  pgAdmin Email       : $PGADMIN_EMAIL"
echo -e "  pgAdmin Password    : $PGADMIN_PASSWORD"
echo -e "  pgAdmin Port        : $PGADMIN_PORT"
echo ""

if [[ -c /dev/tty ]]; then
  read -rp "  Continue with installation? (y/N): " confirm < /dev/tty
else
  read -rp "  Continue with installation? (y/N): " confirm
fi
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled."; exit 0; }

# ── Section 1: System Update ──
section "1/5  System Update"
apt update -y && apt upgrade -y
apt install -y curl wget gnupg2 lsb-release ca-certificates ufw
info "System updated"

# ── Section 2: Nginx ──
section "2/5  Installing Nginx"
apt install -y nginx
systemctl enable nginx
systemctl start nginx

# Nginx config — pgAdmin proxy
cat > /etc/nginx/sites-available/pgadmin <<EOF
server {
    listen ${NGINX_PORT};
    server_name _;

    # pgAdmin
    location /pgadmin/ {
        proxy_pass         http://127.0.0.1:${PGADMIN_PORT}/;
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Script-Name /pgadmin;
        proxy_redirect     off;
        proxy_buffering    off;
        proxy_http_version 1.1;
    }

    # Default
    location / {
        return 200 'Nginx is running!';
        add_header Content-Type text/plain;
    }
}
EOF

ln -sf /etc/nginx/sites-available/pgadmin \
       /etc/nginx/sites-enabled/pgadmin
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
info "Nginx configured"

# ── Section 3: PostgreSQL ──
section "3/5  Installing PostgreSQL"

# Already installed check
if systemctl is-active --quiet postgresql; then
  warn "PostgreSQL already running — skipping reinstall"
  warn "Only adding pgAdmin server entry"
else
  apt install -y postgresql postgresql-contrib
  systemctl enable postgresql
  systemctl start postgresql
fi

# Set postgres password
sudo -u postgres psql -c \
  "ALTER USER postgres WITH PASSWORD '$PG_PASSWORD';" 2>/dev/null || \
  warn "Could not set postgres password — set it manually"

# pg_hba: switch peer → md5 for local connections
PG_HBA=$(sudo -u postgres psql -t -c "SHOW hba_file;" | xargs)
if [[ -f "$PG_HBA" ]]; then
  cp "$PG_HBA" "${PG_HBA}.backup.$(date +%Y%m%d%H%M%S)"
  sed -i "s/^local\s*all\s*all\s*peer/local all all md5/" "$PG_HBA"
  systemctl restart postgresql
  info "PostgreSQL configured (backup saved)"
fi

# ── Section 4: pgAdmin 4 ──
section "4/5  Installing pgAdmin 4"

# Add official pgAdmin repo
curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub \
  | gpg --dearmor -o /etc/apt/trusted.gpg.d/pgadmin.gpg

echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
  > /etc/apt/sources.list.d/pgadmin4.list

apt update -y
apt install -y pgadmin4-web

# Configure pgAdmin
PGADMIN_SETUP_EMAIL="$PGADMIN_EMAIL" \
PGADMIN_SETUP_PASSWORD="$PGADMIN_PASSWORD" \
/usr/pgadmin4/bin/setup-web.sh --yes

# Set custom port
CONFIG_LOCAL="/etc/pgadmin4/config_local.py"
if grep -q "DEFAULT_SERVER_PORT" "$CONFIG_LOCAL" 2>/dev/null; then
  sed -i "s/DEFAULT_SERVER_PORT.*/DEFAULT_SERVER_PORT = ${PGADMIN_PORT}/" "$CONFIG_LOCAL"
else
  echo "DEFAULT_SERVER_PORT = ${PGADMIN_PORT}" >> "$CONFIG_LOCAL"
fi

info "pgAdmin 4 configured"

# ── Section 5: Firewall ──
section "5/5  Firewall Setup"
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP / Nginx
ufw allow 443/tcp   # HTTPS (future SSL)
ufw allow 5050/tcp  # pgAdmin direct
# PostgreSQL (5432) intentionally NOT exposed
info "Firewall configured"

# ── Done ──
SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo -e "${GREEN}${BOLD}"
echo "  ╔═══════════════════════════════════════════╗"
echo "  ║         Installation Complete! ✓          ║"
echo "  ╠═══════════════════════════════════════════╣"
echo -e "  ║  🌐 Nginx       http://${SERVER_IP}        "
echo -e "  ║  🖥  pgAdmin 4   http://${SERVER_IP}/pgadmin/"
echo -e "  ║  🐘 PostgreSQL  ${SERVER_IP}:5432          "
echo "  ╠═══════════════════════════════════════════╣"
echo -e "  ║  pgAdmin Login:                           "
echo -e "  ║    Email    : ${PGADMIN_EMAIL}             "
echo -e "  ║    Password : ${PGADMIN_PASSWORD}          "
echo "  ╠═══════════════════════════════════════════╣"
echo -e "  ║  PostgreSQL:                              "
echo -e "  ║    User     : postgres                    "
echo -e "  ║    Password : ${PG_PASSWORD}               "
echo "  ╚═══════════════════════════════════════════╝"
echo -e "${NC}"
