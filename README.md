# Docker Container for Core Keeper Dedicated Server

A dedicated Core Keeper server based on `cm2network/steamcmd:root`. The entrypoint updates the dedicated server with SteamCMD before each launch.

## Run the server

Use [docker-compose.yml](docker-compose.yml) as a starting point. Set the server identity and password, then run `docker compose up -d --build`.

The image defaults `DATA_PATH` to `/home/steam/core-keeper-dedicated/saves`. The example Compose file instead uses a separate bind mount:

| Host | Container | Purpose |
| --- | --- | --- |
| `/appdata/core-keeper/dedicated` | `/home/steam/core-keeper-dedicated` | Server installation |
| `/appdata/core-keeper/data` | `/home/steam/core-keeper-data` | Worlds and server data |

Keep the data mount when recreating the container. Back up `/appdata/core-keeper/data` before upgrading the server or activating content. `DATA_PATH` must be an absolute, writable path; the entrypoint refuses relative values. In Compose list syntax, `- DATA_PATH=""` passes literal quote characters and is not an empty value. Prefer the mapping syntax shown in the example.

The Compose example gives the server two minutes to stop and finish saving before Docker forcefully terminates it.

For the strato.V80 host, [ops/corekeeper-backup.sh](ops/corekeeper-backup.sh) and its systemd timer copy the complete data directory to `/appdata/core-keeper/backups/daily` at 03:30 UTC each day. The script checks that world 2 stayed unchanged during the copy. The backups have no automatic deletion policy; monitor available disk space.

The `WORLD_ID` is an index within `DATA_PATH`, not a host path. Check that the expected world save exists there before launching an older world with a new server version.

## Activate content on an existing world

The available bundles and their names depend on the installed dedicated server version. Read `ARGUMENTS.txt` in the server installation before choosing bundles. Server version `1.3.0.6-6e73` (Steam build `25825323`) lists `AbioticFactor`, `BiomeStatues`, `GiantCicadaBossDungeon`, `GuaranteedOases`, `LegendaryScepterDungeon`, `MossBiomeDungeons`, and `NatureBiomeCicadas`.

1. Stop the server and back up its data directory.
2. Add `ACTIVATE_CONTENT_BUNDLES` with the desired names from that version's `ARGUMENTS.txt` to `environment` for the intended world, then start the server.
3. Check the server logs and confirm the world save file was written after activation. A world may not save until a player joins. Then remove the environment entry for subsequent starts and verify the bundles remain active.

The server's `-activatecontent` operation is permanent for that world. Some bundles may overwrite explored areas. `ACTIVATE_ALL_CONTENT: "true"` is also available as an explicit opt-in, but keeping it enabled can activate bundles introduced by later updates. Do not set both environment variables together. Neither activation option is enabled by default.

Additional dedicated-server arguments can still be passed to the container command. The documented ENV variables are preferable for regular Compose use.

If SteamCMD cannot update but a server executable is already installed, the entrypoint logs a warning and starts that installed version. Check the game version in the startup log. A stale Steam app manifest can cause `Error! App '1963720' state is 0x6`; after backing up the installation and world data, moving `steamapps/appmanifest_1963720.acf` aside allows SteamCMD to perform a clean download on the next start.
