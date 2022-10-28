#!/bin/bash

set -e
# This entrypoint allows us to provide an nginx config template for nginx sidecar container
echo "Loading entrypoint"

# Set super safe defaults
if [[ -z "${PROXY_ENABLED:-}" ]]
then
  export PROXY_ENABLED="false"
fi

# Set super safe defaults
if [[ -z "${APP_NAME:-}" ]]
then
  export APP_NAME="app"
fi


# This is how we copy the config into a volume (must be mounted). Then nginx config is picked up by nginx container.
# Then it is being passed through envsubst.
if [[ "$PROXY_ENABLED" == "true" ]]
then
  echo "PROXY_ENABLED=true"
  cp /app/nginx.conf.template /etc/nginx/templates/default.conf.template
  echo "Nginx proxy template copied to /etc/nginx/templates/default.conf.template"

  cp -dR /app/public /etc/nginx/app
  echo "/app/public directory copied to /etc/nginx/app/public"

  echo "Starting ${APP_NAME}: $*"
fi

python /app/app.py