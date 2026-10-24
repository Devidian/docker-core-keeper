#!/bin/bash
# VARIABLES
export LD_LIBRARY_PATH="${STEAM_APP_DIR}/linux64:$LD_LIBRARY_PATH:../Steamworks SDK Redist/linux64/"

if [[ "$DATA_PATH" != /* || "$DATA_PATH" == / ]]; then
	echo "DATA_PATH must be an absolute directory path (without literal quotation marks)." >&2
	exit 1
fi

if [[ -n "$ACTIVATE_CONTENT_BUNDLES" && ! "$ACTIVATE_CONTENT_BUNDLES" =~ ^[[:alnum:]]+(,[[:alnum:]]+)*$ ]]; then
	echo "ACTIVATE_CONTENT_BUNDLES must be a comma-separated list of bundle names." >&2
	exit 1
fi

if [[ "$ACTIVATE_ALL_CONTENT" != true && "$ACTIVATE_ALL_CONTENT" != false ]]; then
	echo "ACTIVATE_ALL_CONTENT must be true or false." >&2
	exit 1
fi

if [[ -n "$ACTIVATE_CONTENT_BUNDLES" && "$ACTIVATE_ALL_CONTENT" == true ]]; then
	echo "Choose either ACTIVATE_CONTENT_BUNDLES or ACTIVATE_ALL_CONTENT, not both." >&2
	exit 1
fi

mkdir -p "$DATA_PATH" || exit 1
if [[ ! -w "$DATA_PATH" ]]; then
	echo "DATA_PATH is not writable: $DATA_PATH" >&2
	exit 1
fi

server_args=(-batchmode -logfile /proc/self/fd/1)
[[ -n "$SERVER_PORT" ]] && server_args+=(-port "$SERVER_PORT")
server_args+=(-maxplayers "$MAX_PLAYERS")
[[ -n "$SERVER_NAME" ]] && server_args+=(-name "$SERVER_NAME")
[[ -n "$SERVER_PASSWORD" ]] && server_args+=(-password "$SERVER_PASSWORD")
[[ -n "$SERVER_PUBLIC" ]] && server_args+=(-public "$SERVER_PUBLIC")
[[ -n "$GAME_ID" ]] && server_args+=(-gameid "$GAME_ID")
server_args+=(-datapath "$DATA_PATH" -worldname "$WORLD_NAME" -world "$WORLD_ID")
[[ -n "$WORLD_SEED" ]] && server_args+=(-worldseed "$WORLD_SEED")
[[ -n "$WORLD_MODE" ]] && server_args+=(-worldmode "$WORLD_MODE")
[[ -n "$WORLD_SIZE" ]] && server_args+=(-worldsize "$WORLD_SIZE")
[[ -n "$ACTIVATE_CONTENT_BUNDLES" ]] && server_args+=(-activatecontent "$ACTIVATE_CONTENT_BUNDLES")
[[ "$ACTIVATE_ALL_CONTENT" == true ]] && server_args+=(-activateallcontent)

echo "Running $STEAMCMDDIR/steamcmd.sh"
echo "Installing app <${STEAM_APP_ID}> into <$STEAM_APP_DIR> for user $(whoami)"

if ! "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "$STEAM_APP_DIR" +login anonymous +app_update "$STEAM_APP_ID" validate +app_update "$STEAM_TOOL_ID" validate +quit; then
	if [[ ! -x "$STEAM_APP_DIR/CoreKeeperServer" ]]; then
		echo "SteamCMD update failed and no installed server executable is available." >&2
		exit 1
	fi
	echo "SteamCMD update failed; starting the already installed server version." >&2
fi

echo "Starting _launch script"
# Copy of _launch.sh to change logfile

xvfbpid=""
ckpid=""
exepath="$STEAM_APP_DIR/CoreKeeperServer"
requirements=( "libxi6" "xvfb" )

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
trap 'exit 0' TERM INT

for r in "${requirements[@]}"
do
	echo "Checking for required package: $r"
	if ! (dpkg -l $r >/dev/null); then
		echo "Installing missing package: $r"
		sleep 1
		$sudo apt-get update -yy && $sudo apt-get install -yy "$r"
	fi
done

set -m

rm -f /tmp/.X99-lock

Xvfb :99 -screen 0 1x1x24 -nolisten tcp &
xvfbpid=$!

chmod +x "$exepath"

DISPLAY=:99 LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$STEAM_APP_DIR/../Steamworks SDK Redist/linux64/" \
        "$exepath" "${server_args[@]}" "$@" &

ckpid=$!

echo "Started server process with pid $ckpid"

wait "$ckpid"
server_status=$?
ckpid=""
exit "$server_status"
