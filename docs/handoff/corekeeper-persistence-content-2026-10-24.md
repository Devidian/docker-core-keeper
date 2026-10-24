# Core Keeper persistence and content activation handoff

## State

- Repository changes: persistent default save path, quoted server arguments, explicit `ACTIVATE_CONTENT_BUNDLES` and `ACTIVATE_ALL_CONTENT` ENV controls, SteamCMD fallback, shutdown handling, Compose example, documentation, and daily backup units.
- Local syntax and Compose checks passed. A local Docker image build on strato.V80 passed (`core-keeper-dedicated:local-20261024`). No public image was published.
- Production remains on `devidian/core-keeper-dedicated:latest` with the patched repository `entrypoint.sh` bind-mounted from `/docker/games/compose/corekeeper-entrypoint.sh`.
- Production Compose fragment: `/docker/games/compose/corekeeper.yml`, project `omega-games`. The root `/docker/games/docker-compose.yml` currently fails validation because of an unrelated duplicate `vsserver` container name; use the Core Keeper fragment for this service.
- World 2 is stored in `/appdata/core-keeper/data/worlds/2.world.gzip` via a separate bind mount. The installation remains in `/appdata/core-keeper/dedicated`.
- Server version is `1.3.0.6-6e73`, Steam build `25825323`. `BiomeStatues`, `LegendaryScepterDungeon`, and `MossBiomeDungeons` were activated and remained active after a restart. The Compose activation value is empty for future starts. The currently running container was created while the explicit three-name value was set; its in-memory ENV clears on the next Compose recreation.
- TCP and UDP 17000 plus UDP 17001 are published. A player connected by Steam Game ID after the port fix. Direct IP joining has not been confirmed after the fix.
- The world file changed after the player joined. A matching backup was created in `/appdata/core-keeper/backups/daily/20261024T153740Z`.
- `corekeeper-backup.timer` is enabled for 03:30 UTC daily. It runs `/docker/games/scripts/corekeeper-backup.sh` and keeps backups without automatic deletion. Earlier pre-cutover and pre-upgrade copies are under `/appdata/core-keeper/backups`.

## Decisions and limits

- Content activation requires explicit ENV values and is never enabled by default. Existing worlds can be changed permanently, including explored terrain.
- SteamCMD failed to update the old install manifest with `Access Denied`. An isolated clean install succeeded, and the previous installation was preserved under `/appdata/core-keeper/backups/preupgrade-install-build19858263`.
- Backups are on the same host filesystem. An off-host backup target is still advisable for disk or host loss.
- Do not interrupt active players just to clear the old container's explicit content ENV. The Compose source is already cleared; a future controlled recreation will pick it up.
