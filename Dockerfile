FROM dunglas/frankenphp:latest-php8.3

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    libzip-dev libpq-dev libsqlite3-dev nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions including SQLite
RUN install-php-extensions \
    pdo pdo_sqlite pdo_mysql pdo_pgsql \
    gd zip opcache intl \
    redis pcntl sqlite3

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# Copy package files for Node dependencies
COPY package*.json ./

# Install Node dependencies and build assets
RUN npm ci && npm run build

# Copy application files
COPY . .

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

# Expose port
EXPOSE 8000

# Start Octane
CMD ["php", "artisan", "octane:start", "--host=0.0.0.0", "--port=8000", "--max-requests=500"]