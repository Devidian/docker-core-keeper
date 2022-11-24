#!/bin/bash
# VARIABLES
export LD_LIBRARY_PATH="${STEAM_APP_DIR}/linux64:$LD_LIBRARY_PATH:../Steamworks SDK Redist/linux64/"

echo "Running $STEAMCMDDIR/steamcmd.sh"
echo "Installing app <${STEAM_APP_ID}> into <$STEAM_APP_DIR> for user $(whoami)"

${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${STEAM_APP_DIR} +login anonymous +app_update ${STEAM_APP_ID} validate +app_update ${STEAM_TOOL_ID} validate +quit

echo "Starting _launch script"
# Copy of _launch.sh to change logfile

xvfbpid=""
ckpid=""
exepath="$STEAM_APP_DIR/CoreKeeperServer"

echo "Execution path: $exepath"

function kill_corekeeperserver {
        if [[ ! -z "$ckpid" ]]; then
                kill $ckpid
                wait $ckpid
        fi
        if [[ ! -z "$xvfbpid" ]]; then
                kill $xvfbpid
                wait $xvfbpid
        fi
}

trap kill_corekeeperserver EXIT

if ! (dpkg -l xvfb >/dev/null) ; then
    echo "Installing xvfb dependency..."
    sleep 1
    sudo apt-get update -yy && sudo apt-get install xvfb -yy
fi

set -m

rm -f /tmp/.X99-lock

Xvfb :99 -screen 0 1x1x24 -nolisten tcp &
xvfbpid=$!

rm -f GameID.txt

chmod +x "$exepath"

DISPLAY=:99 LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$STEAM_APP_DIR/../Steamworks SDK Redist/linux64/" \
        "$exepath" -batchmode -logfile /proc/self/fd/1 \
        -gameid ${GAME_ID} \
        -datapath ${DATA_PATH} \
        -worldname ${WORLD_NAME} \
        -world ${WORLD_ID} \
        -worldseed ${WORLD_SEED} \
        -worldmode ${WORLD_MODE} \
        -maxplayers ${MAX_PLAYERS} "$@" &

ckpid=$!

echo "Started server process with pid $ckpid"

while [ ! -f GameID.txt ]; do
        sleep 0.1
done

echo "Game ID: $(cat GameID.txt)"

wait $ckpid
ckpid=""
