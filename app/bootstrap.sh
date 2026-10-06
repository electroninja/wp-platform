#!/bin/sh
set -e

WP_PATH=/var/www/html/web/wp

echo "Waiting for the database..."
until wp db check --path="$WP_PATH" --allow-root 2>/dev/null; do
  sleep 2
done

if ! wp core is-installed --path="$WP_PATH" --allow-root; then
  echo "Installing WordPress..."
  wp core install \
    --path="$WP_PATH" \
    --url="${WP_HOME}" \
    --title="${WP_TITLE:-My Platform}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email --allow-root
else
  echo "WordPress already installed — skipping core install."
fi

wp rewrite structure '/%postname%/' --path="$WP_PATH" --allow-root
wp plugin activate redis-cache --path="$WP_PATH" --allow-root
wp redis enable --path="$WP_PATH" --allow-root

echo "Bootstrap complete."
