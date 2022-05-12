# Docker Container for Core Keeper Dedicated Server

TBD

# How to run it

Best way is to use a composer file like this:

```yml
version: '3.8'

services:
  core-keeper-ds-docker:
    image: devidian/core-keeper-dedicated:latest
    container_name: core-keeper-ds-docker
    restart: unless-stopped
    volumes:
      # left side: your docker-host machine
      # right side: the paths in the image (!!do not change!!)
      - /appdata/core-keeper/dedicated:/home/steam/core-keeper-dedicated
```

and run `docker-compose up -d`.