FROM cm2network/steamcmd:root

RUN apt update && apt upgrade -y &&\
	apt-get install -qq -y --install-recommends \
	xvfb

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

USER ${USER}

VOLUME ${STEAM_APP_DIR}

WORKDIR ${HOMEDIR}

CMD ["bash", "entrypoint.sh"]