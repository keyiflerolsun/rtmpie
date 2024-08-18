#!/usr/bin/env bash

set -o pipefail

if [ -f .env ]; then
  rm .env
fi

if [ -f rtmpie.conf ]; then
  rm rtmpie.conf
fi

rand() {
  echo `cat /dev/urandom | env LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
}


if [ -f rtmpie.conf ]; then
  echo "The config file does already exist. If you want to proceed, please run \"rm rtmpie.conf\" first."
  exit 1
fi

wget -q -O docker-compose.yml https://github.com/keyiflerolsun/rtmpie/blob/hls/docker-compose.yml?raw=True

while [ -z "${RTMPIE_HOSTNAME}" ]; do
  read -p "Enter the hostname you want to use for RTMPie (e.g. 127.0.0.1 or demo.rtmpie.de): " -e RTMPIE_HOSTNAME
done

read -r -p  "Do you want to enable SSL (access the application using https:// instead of http://) (recommended)? [Y/n] " response
case $response in
  [nN][oO]|[nN])
    RTMPIE_HTTP_SCHEME=http
    RTMPIE_CADDY_SERVER_NAME="${RTMPIE_HOSTNAME}:80"
    ;;
  *)
    RTMPIE_HTTP_SCHEME=https
    RTMPIE_CADDY_SERVER_NAME="${RTMPIE_HOSTNAME}"
  ;;
esac

RTMPIE_APP_SECRET=$(rand)
RTMPIE_MERCURE_JWT_KEY=$(rand)
RTMPIE_DATABASE_PASSWORD=$(rand)

cat << EOF > rtmpie.conf
RTMPIE_HOSTNAME=${RTMPIE_HOSTNAME}
RTMPIE_HTTP_SCHEME=${RTMPIE_HTTP_SCHEME}
RTMPIE_CADDY_SERVER_NAME=${RTMPIE_CADDY_SERVER_NAME}

# Auto-generated credentials for internal use
RTMPIE_APP_SECRET=${RTMPIE_APP_SECRET}
RTMPIE_MERCURE_JWT_KEY=${RTMPIE_MERCURE_JWT_KEY}
RTMPIE_DATABASE_PASSWORD=${RTMPIE_DATABASE_PASSWORD}

EOF

ln -s rtmpie.conf .env
