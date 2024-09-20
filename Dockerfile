FROM cm2network/steamcmd:root

WORKDIR ${HOMEDIR}

# Steamworks
ENV STEAM_TOOL_ID 1007
ENV STEAM_APP_ID 1963720
ENV STEAM_APP_NAME core-keeper
ENV STEAM_APP_DIR "${HOMEDIR}/${STEAM_APP_NAME}-dedicated"

COPY entrypoint.sh ${HOMEDIR}/entrypoint.sh
RUN mkdir ${STEAM_APP_DIR} && \
	chmod +x "${HOMEDIR}/entrypoint.sh" && \
	chown -R "${USER}:${USER}" "${HOMEDIR}"

# Default server arguments
ENV GAME_ID="" \
	DATA_PATH="" \
	WORLD_NAME="Core Keeper Dedicated Docker Server" \
	WORLD_ID=0 \
	WORLD_SEED=0 \
	WORLD_MODE=0 \
	MAX_PLAYERS=4 

RUN apt update && \
	apt install -y \
	libxi6 \
	xvfb

ENTRYPOINT ["./entrypoint.sh"]