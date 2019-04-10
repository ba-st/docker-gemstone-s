#!/usr/bin/env bash

# based on https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86
# see also https://docs.docker.com/engine/reference/builder/#exec-form-entrypoint-example

set -eu

# SIGUSR1-handler
my_handler() {
  echo 'Got SIGUSR1'
}

# SIGTERM-handler
term_handler() {
  echo 'Got SIGTERM, stopping GemStone'
  stopnetldi
  stopstone -i gemserver66 DataCurator swordfish
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, 
# which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; my_handler' SIGUSR1
trap 'kill ${!}; term_handler' SIGTERM

# start GemStone services
# shellcheck disable=SC2086
startnetldi -g -a "$GS_USER" -n ${NETLDI_ARGS:-}
# shellcheck disable=SC2086
startstone -e /opt/gemstone/conf -z /opt/gemstone/conf -l /opt/gemstone/log/stone.log ${STONE_ARGS:-}

# list GemStone servers
gslist -cvl

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done