#!/usr/bin/env bash

set -eu

echo "${NETLDI} ${NETLDI_PORT}/tcp #GemStone - Netldi" >> /etc/services
echo "${STONE} ${STONE_PORT}/tcp #GemStone - Stone" >> /etc/services

if [ ! -f /opt/gemstone/data/extent0.dbf ]; then
  cp -p "$GEMSTONE"/bin/extent0.dbf /opt/gemstone/data/extent0.dbf
fi

if ! gosu "$GS_USER" test -w /opt/gemstone/data/extent0.dbf; then
  chmod ug+w /opt/gemstone/data/extent0.dbf
fi

gosu "$GS_USER" /opt/gemstone/gemstone.sh
