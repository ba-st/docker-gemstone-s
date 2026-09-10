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

# exec so that gemstone.sh replaces this shell as PID 1 (gosu execs too).
# Without it bash stays PID 1 and does not forward the SIGTERM sent by
# "docker stop", so the trap in gemstone.sh never stops the stone.
exec gosu "$GS_USER" /opt/gemstone/gemstone.sh
