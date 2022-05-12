FROM cm2network/steamcmd:root

RUN apt update && apt upgrade -y &&\
    apt-get install -qq -y --install-recommends \
    xvfb

ENV STEAMAPPID 1963720
ENV STEAMAPP core-keeper
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"

COPY entrypoint.sh ${HOMEDIR}/entrypoint.sh
RUN chmod +x "${HOMEDIR}/entrypoint.sh" && chown -R "${USER}:${USER}" "${HOMEDIR}"

# Default server arguments
ENV GAME_ID="" \
	DATA_PATH="" \
	WORLD_NAME="Core Keeper Dedicated Docker Server" \
    WORLD_ID=0 \
	WORLD_SEED=0 \
	MAX_PLAYERS=4 

USER ${USER}

VOLUME ${STEAMAPPDIR}

WORKDIR ${HOMEDIR}

CMD ["bash", "entrypoint.sh"]