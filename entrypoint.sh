#!/bin/bash
# VARIABLES
export LD_LIBRARY_PATH="${STEAM_APP_DIR}/linux64:$LD_LIBRARY_PATH:../Steamworks SDK Redist/linux64/"
export DISPLAY=:99

echo "Running $STEAMCMDDIR/steamcmd.sh"
echo "Installing app <${STEAM_APP_ID}> into <$STEAM_APP_DIR> for user $(whoami)"

${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${STEAM_APP_DIR} +login anonymous +app_update ${STEAM_APP_ID} validate +app_update ${STEAM_TOOL_ID} validate +quit

cd ${STEAM_APP_DIR}

echo "Removing x99-lock and GameID files"
rm -f /tmp/.X99-lock
rm -f GameID.txt

echo "Starting Xvfb server"
Xvfb :99 -screen 0 1x1x24 -nolisten tcp -nolisten unix &

echo "Starting game server"
DISPLAY=:99 LD_LIBRARY_PATH="$LD_LIBRARY_PATH:../Steamworks SDK Redist/linux64/" \
    ${STEAM_APP_DIR}/CoreKeeperServer \
        -batchmode \
        -gameid ${GAME_ID} \
        -datapath ${DATA_PATH} \
        -worldname ${WORLD_NAME} \
        -world ${WORLD_ID} \
        -worldseed ${WORLD_SEED} \
        -maxplayers ${MAX_PLAYERS} \
        -logfile /proc/self/fd/1