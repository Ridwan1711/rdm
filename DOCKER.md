# Docker Deployment untuk RDM (Rapor Digital Madrasah)

File Docker ini dibuat untuk memenuhi syarat hosting RDM:

- ✅ PHP 7.2
- ✅ ionCube Loader PHP 7.2
- ✅ allow_url_fopen enabled
- ✅ CURL aktif
- ✅ Apache dengan mod_rewrite

## Struktur File

- `Dockerfile` - Konfigurasi Docker image
- `docker-compose.yml` - Setup lengkap dengan database dan phpMyAdmin
- `.dockerignore` - File yang diabaikan saat build

## Cara Menggunakan

### 1. Build dan Run dengan Docker Compose (Recommended)

```bash
# Build dan start semua services
docker-compose up -d

# Lihat logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop dan hapus volumes (database akan terhapus)
docker-compose down -v
```

Setelah container berjalan:
- **Aplikasi RDM**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081

### 2. Build dan Run Manual

```bash
# Build image
docker build -t rdm-app .

# Run container
docker run -d \
  --name rdm-app \
  -p 8080:80 \
  -v $(pwd)/application/config:/var/www/html/application/config \
  rdm-app
```

## Konfigurasi Database

1. Edit file `application/config/database.php`:
   - `hostname`: `db` (jika menggunakan docker-compose) atau IP database server
   - `username`: `rdm_user` (atau sesuai konfigurasi)
   - `password`: `rdm_password` (atau sesuai konfigurasi)
   - `database`: `rdm_database` (atau sesuai konfigurasi)

2. Untuk docker-compose, database credentials default:
   - Host: `db`
   - Username: `rdm_user`
   - Password: `rdm_password`
   - Database: `rdm_database`

## Environment Variables

Anda bisa mengubah konfigurasi database di `docker-compose.yml` pada section `db`:

```yaml
environment:
  MYSQL_ROOT_PASSWORD: your_root_password
  MYSQL_DATABASE: your_database_name
  MYSQL_USER: your_username
  MYSQL_PASSWORD: your_password
```

## Troubleshooting

### ionCube Loader tidak berfungsi

Cek apakah ionCube Loader terinstall:
```bash
docker exec rdm-app php -m | grep ioncube
```

Jika tidak muncul, cek logs:
```bash
docker-compose logs web
```

### allow_url_fopen tidak aktif

Verifikasi:
```bash
docker exec rdm-app php -i | grep allow_url_fopen
```

Seharusnya menampilkan: `allow_url_fopen => On => On`

### CURL tidak aktif

Verifikasi:
```bash
docker exec rdm-app php -m | grep curl
```

### Permission Error

Jika ada permission error pada cache/logs:
```bash
docker exec rdm-app chmod -R 777 /var/www/html/application/cache
docker exec rdm-app chmod -R 777 /var/www/html/application/logs
```

## Production Deployment

Untuk production, disarankan:

1. Gunakan environment variables untuk sensitive data
2. Setup reverse proxy (nginx) di depan Apache
3. Enable SSL/TLS certificates
4. Gunakan managed database service (jangan gunakan container database untuk production)
5. Setup backup rutin
6. Monitor logs dan performance

## Catatan

- Port default: 8080 (web), 8081 (phpMyAdmin), 3306 (MySQL)
- Volume untuk config, logs, dan cache sudah di-mount untuk persist data
- Database data tersimpan di Docker volume `db_data`
