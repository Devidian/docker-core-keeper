# Docker Container for Core Keeper Dedicated Server

A dedicated server for `core keeper` based on `cm2network/steamcmd:root`

# How to run it

Best way is to use a composer file like this:

```yml
services:
  core-keeper-ds-docker:
    image: devidian/core-keeper-dedicated:latest
    container_name: core-keeper-ds-docker
    restart: unless-stopped
    environment:
      # Game ID to use for the server. Need to be at least 23 characters and alphanumeric, excluding Y,y,x,0,O. Empty or not valid means a new ID will be generated at start.
      - GAME_ID=""
      # Save file location. If not set it defaults to a subfolder named "DedicatedServer" at the default Core Keeper save location.
      - DATA_PATH=""
      # The name to use for the server.
      - SERVER_NAME="Core Keeper Dedicated Docker Server"
      # Which world index to use.
      - WORLD_ID=0
      # The seed to use for a new world. Set to 0 to generate random seed.
      - WORLD_SEED=0
      # Whether to use normal (0) or hard (1) mode for world.
      - WORLD_MODE=normal
      # Maximum number of players that will be allowed to connect to server.
      - MAX_PLAYERS=4
      # server port
      - SERVER_PORT=17000
      # 1 - 4 
      - WORLD_SIZE=1
      - WORLD_NAME="Default Docker World"
      - SERVER_PUBLIC=false
      - SERVER_PASSWORD=defaultPassword
    # If you dont like to use a directory on the host just comment volumes section
    volumes:
      # left side: your docker-host machine
      # right side: the paths in the image (!!do not change!!)
      - /appdata/core-keeper/dedicated:/home/steam/core-keeper-dedicated
```

and run `docker-compose up -d`.

# Issues, suggestions & contribution

Please use [GitHub](https://github.com/Devidian/docker-core-keeper/issues)