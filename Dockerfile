FROM dunglas/frankenphp:latest-php8.3

# Install system dependencies including Node.js 20
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    libzip-dev libpq-dev libsqlite3-dev ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Verify Node.js version
RUN node --version && npm --version

# Install PHP extensions
RUN install-php-extensions \
    pdo pdo_sqlite pdo_mysql pdo_pgsql \
    gd zip opcache intl \
    redis pcntl sqlite3

# Verify PHP is available and in PATH
RUN which php || (find / -name php 2>/dev/null | head -1)
RUN php --version

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy composer files and install PHP dependencies FIRST
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy package files
COPY package*.json ./

# Install Node dependencies
RUN npm ci

# Copy all application files
COPY . .

# Build frontend assets (vendor directory now exists)
RUN npm run build

# Complete Composer installation
RUN composer dump-autoload --optimize --classmap-authoritative

# Create database directory
RUN mkdir -p /app/database && \
    touch /app/database/database.sqlite

# Set permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache /app/database && \
    chmod -R 775 /app/storage /app/bootstrap/cache /app/database

# Laravel optimizations
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

EXPOSE 8000

CMD ["php", "artisan", "octane:start", "--host=0.0.0.0", "--port=8000", "--max-requests=500"]