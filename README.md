# 🚀 Nginx + PostgreSQL + pgAdmin 4 — Auto Installer

One command দিয়ে **Nginx**, **PostgreSQL**, এবং **pgAdmin 4** install ও configure করুন।

**Supports:** Ubuntu 20.04 / 22.04 / 24.04 · Debian 11 / 12

---

## ⚡ One Command Install

```bash
curl -fsSL https://raw.githubusercontent.com/rubeltechcom/nginx-postgres-pgadmin/main/install.sh | sudo bash
```

### Custom পাসওয়ার্ড দিয়ে install করুন

```bash
curl -fsSL https://raw.githubusercontent.com/rubeltechcom/nginx-postgres-pgadmin/main/install.sh \
  | sudo PG_PASSWORD="আপনার_পাসওয়ার্ড" \
         PGADMIN_EMAIL="আপনার@email.com" \
         PGADMIN_PASSWORD="আপনার_পাসওয়ার্ড" \
         bash
```

---

## 📥 Manual Install (Recommended for Production)

```bash
# 1. Repository clone করুন
git clone https://github.com/rubeltechcom/nginx-postgres-pgadmin.git
cd nginx-postgres-pgadmin

# 2. Script টি executable করুন
chmod +x install.sh

# 3. install.sh খুলে পাসওয়ার্ড পরিবর্তন করুন
nano install.sh

# 4. Run করুন
sudo ./install.sh
```

---

## 🌐 Installation এর পরে

| Service | URL / Address |
|---|---|
| pgAdmin 4 | `http://YOUR_SERVER_IP/pgadmin/` |
| File Manager | `http://YOUR_SERVER_IP/files/` |
| Nginx | `http://YOUR_SERVER_IP` |
| PostgreSQL | `YOUR_SERVER_IP:5432` |

---

## ⚙️ Environment Variables

| Variable | Default | বিবরণ |
|---|---|---|
| `PG_PASSWORD` | `StrongPass@1234` | PostgreSQL postgres user password |
| `PGADMIN_EMAIL` | `admin@local.com` | pgAdmin login email |
| `PGADMIN_PASSWORD` | `Admin@1234` | pgAdmin login password |
| `PGADMIN_PORT` | `5050` | pgAdmin internal port |
| `NGINX_PORT` | `80` | Nginx port |

---

## 🔒 Production এর জন্য

### SSL Certificate (HTTPS) লাগান
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

### pgAdmin প্রয়োজনে চালু/বন্ধ করুন
```bash
sudo systemctl stop apache2    # কাজ শেষে বন্ধ
sudo systemctl start apache2   # দরকার হলে চালু
```

### LAN এর অন্য PC থেকে access
Same network এ থাকলে server এর IP দিয়ে সরাসরি access করুন:
```
http://192.168.1.XXX/pgadmin/
```

---

## 📋 কী কী install হয়

- ✅ **Nginx** — Web server + pgAdmin reverse proxy
- ✅ **PostgreSQL** — Database server
- ✅ **pgAdmin 4** — Web-based DB management UI
- ✅ **FileBrowser** — (Optional) cPanel-like Web File Manager
- ✅ **UFW Firewall** — Basic firewall rules
- ✅ **pg_hba.conf** — Auto backup নেওয়া হয়

---

## 🛠 Troubleshooting

### pgAdmin খুলছে না
```bash
sudo systemctl status apache2
sudo journalctl -u apache2 -n 50
```

### PostgreSQL connect হচ্ছে না
```bash
sudo systemctl status postgresql
sudo -u postgres psql  # direct connect test
```

### Nginx error
```bash
sudo nginx -t
sudo systemctl status nginx
```

---

## 📄 License

MIT License — যে কেউ ব্যবহার করতে পারবেন।
