FROM cm2network/steamcmd:root

RUN apt update && apt upgrade -y &&\
    apt-get install -qq -y --install-recommends \
    xvfb

ENV STEAMAPPID 1963720
ENV STEAMAPP core-keeper
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"

COPY entrypoint.sh ${HOMEDIR}/entrypoint.sh
RUN chmod +x "${HOMEDIR}/entrypoint.sh" && chown -R "${USER}:${USER}" "${HOMEDIR}"

USER ${USER}

VOLUME ${STEAMAPPDIR}

WORKDIR ${HOMEDIR}

CMD ["bash", "entrypoint.sh"]

EXPOSE 27015/udp 27016/udp