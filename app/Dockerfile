# ---- Stage 1: install PHP dependencies with Composer ----
FROM composer:2.7 AS build
WORKDIR /app
COPY app/bedrock/composer.json app/bedrock/composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist
COPY app/bedrock/ ./
RUN composer dump-autoload --optimize

# ---- Stage 2: runtime image ----
FROM php:8.3-fpm-alpine AS runtime

RUN apk add --no-cache icu-dev libzip-dev fcgi \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && docker-php-ext-install pdo pdo_mysql opcache intl zip \
    && apk del .build-deps

# non-root user — see Step 4
RUN addgroup -g 1000 app && adduser -D -u 1000 -G app app

WORKDIR /var/www/html
COPY --from=build --chown=app:app /app ./

# enable fpm's built-in ping/status endpoints for the healthcheck
RUN { \
      echo 'pm.status_path = /status'; \
      echo 'ping.path = /ping'; \
      echo 'listen = 9000'; \
      echo 'user = app'; \
      echo 'group = app'; \
    } >> /usr/local/etc/php-fpm.d/zz-app.conf

USER app

HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET \
      cgi-fcgi -bind -connect 127.0.0.1:9000 || exit 1

EXPOSE 9000
CMD ["php-fpm"]
