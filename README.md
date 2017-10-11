# Docker Mongo

## Setup

To download latest backup from AWS and set up local replica set.

```
docker-compose up -d
docker-compose run --rm mongo ./app/setup.sh
```

If you get any errors, like `Failed: no reachable servers`, stop and remove containers,
and then try again.

```
docker-compose stop
docker-compose rm -f
```

Also, remember to add appropriate secrets.
