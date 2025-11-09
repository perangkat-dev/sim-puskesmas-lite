# Gunakan image PHP 8.3 dengan Apache (stabil dan didukung Render)
FROM php:8.3-apache

# Instal ekstensi dan utilitas yang dibutuhkan Laravel + Filament
RUN apt-get update && apt-get install -y \
    git unzip libpng-dev libonig-dev libxml2-dev zip curl libzip-dev sqlite3 \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd zip

# Aktifkan mod_rewrite agar route Laravel berfungsi
RUN a2enmod rewrite

# Set direktori kerja
WORKDIR /var/www/html

# Salin semua file project ke container
COPY . .

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install dependency Laravel tanpa dev packages
RUN composer install --no-dev --optimize-autoloader

# Buat file .env dari contoh (jika belum ada)
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Generate app key
RUN php artisan key:generate

# Buat folder database untuk SQLite dan beri izin tulis
RUN mkdir -p database && touch database/database.sqlite && chmod -R 777 database storage bootstrap/cache

# Ganti konfigurasi Apache agar Laravel bisa diakses dari root
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
</Directory>" > /etc/apache2/conf-available/laravel.conf \
    && a2enconf laravel

# Expose port 80 untuk akses web
EXPOSE 80

# Jalankan Apache saat container start
CMD ["apache2-foreground"]
