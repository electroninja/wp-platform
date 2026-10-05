# Stage 1: install PHP dependencies with Composer
FROM composer:2.7 AS build
WORKDIR /app
COPY bedrock/composer.json bedrock/composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist
COPY bedrock/ ./
RUN composer dump-autoload --optimize

# Stage 2: runtime image
FROM php:8.3-fpm-alpine AS runtime


# hadolint ignore=DL3018,SC2086
RUN apk add --no-cache icu-dev libzip-dev fcgi \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-install pdo pdo_mysql opcache intl zip \
    && docker-php-ext-install mysqli pdo_mysql intl zip \
    && apk del .build-deps

# Create non-root user
RUN addgroup -g 1000 app && adduser -D -u 1000 -G app app

WORKDIR /var/www/html
COPY --from=build --chown=1000:1000 /app ./

# Enable fpm ping/status endpoints
RUN { \
      echo 'pm.status_path = /status'; \
      echo 'ping.path = /ping'; \
      echo 'listen = 9000'; \
      echo 'user = app'; \
      echo 'group = app'; \
    } >> /usr/local/etc/php-fpm.d/zz-app.conf

USER 1000:1000

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD ["cgi-fcgi", "-bind", "-connect", "127.0.0.1:9000"]

EXPOSE 9000
CMD ["php-fpm"]
