# Stage 1: Build frontend with Node 22
FROM node:22-alpine AS frontend-builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY resources ./resources
COPY public ./public
COPY vite.config.js ./
COPY tailwind.config.js* ./
COPY postcss.config.js* ./

RUN npm run build

# Stage 2: Runtime with FrankenPHP
FROM dunglas/frankenphp:latest-php8.3

RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    libzip-dev libpq-dev libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN install-php-extensions \
    pdo pdo_sqlite pdo_mysql pdo_pgsql \
    gd zip opcache intl \
    redis pcntl sqlite3

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

COPY . .
COPY --from=frontend-builder /app/public/build ./public/build

RUN composer dump-autoload --optimize --classmap-authoritative

RUN mkdir -p /app/database && \
    touch /app/database/database.sqlite

RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache /app/database && \
    chmod -R 775 /app/storage /app/bootstrap/cache /app/database

RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

EXPOSE 8000

CMD ["php", "artisan", "octane:start", "--host=0.0.0.0", "--port=8000", "--max-requests=500"]