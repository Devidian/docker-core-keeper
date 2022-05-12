#!/bin/bash
# VARIABLES
export LD_LIBRARY_PATH="${STEAMAPPDIR}/linux64:$LD_LIBRARY_PATH:../Steamworks SDK Redist/linux64/"

${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} validate +quit

cd ${STEAMAPPDIR}

echo "Starting Server"

rm -f /tmp/.X99-lock

Xvfb :99 -screen 0 1x1x24 -nolisten tcp -nolisten unix &
DISPLAY=:99 \
./CoreKeeperServer \
    -batchmode \
    -gameid ${GAME_ID} \
    -datapath ${DATA_PATH} \
    -worldname ${WORLD_NAME} \
    -world ${WORLD_ID} \
    -worldseed ${WORLD_SEED} \
    -maxplayers ${MAX_PLAYERS} \
    -logfile /proc/self/fd/1