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

## 🚀 অ্যাপ্লিকেশন হোস্টিং এবং সার্ভার কনফিগারেশন

আপনি **File Manager** (FileBrowser) ব্যবহার করে খুব সহজেই আপনার প্রজেক্ট আপলোড এবং সার্ভার কনফিগার করতে পারবেন। File Manager-এর রুট ডিরেক্টরি পুরো সার্ভার (`/`) সেট করা আছে।

### ১. স্ট্যাটিক ওয়েবসাইট বা প্রজেক্ট আপলোড (HTML/CSS/JS)
- File Manager-এ লগইন করুন (`http://YOUR_SERVER_IP/files/`)।
- `var` > `www` > `html` ফোল্ডারে যান।
- আপনার ওয়েবসাইটের ফাইলগুলো এখানে আপলোড করুন। 
- এরপর আপনার সার্ভারের IP-তে ভিজিট করলেই ওয়েবসাইটটি দেখতে পাবেন।

### ২. সার্ভার কনফিগারেশন এডিট করা (Nginx)
- Nginx-এর কোনো সেটিংস পরিবর্তন করতে হলে File Manager থেকে `etc` > `nginx` > `sites-available` ফোল্ডারে যান।
- `pgadmin` (বা আপনার সাইটের কনফিগ) ফাইলটি ওপেন করে এডিট ও সেভ করুন।
- এরপর টার্মিনালে `sudo systemctl reload nginx` কমান্ড রান করুন।

### ৩. PHP বা Node.js প্রজেক্ট হোস্টিং
- **PHP:** আপনার যদি PHP প্রজেক্ট হয়, তবে টার্মিনাল থেকে `sudo apt install php-fpm php-pgsql` রান করে Nginx কনফিগারেশন আপডেট করে নিন।
- **Node.js:** Node.js অ্যাপ হলে প্রজেক্ট আপলোড করে PM2 দিয়ে রান করান এবং Nginx-এ রিভার্স প্রক্সি কনফিগার করুন।

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
