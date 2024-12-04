#!/bin/bash

# ensures that the script exits immediately if any command exits with a non-zero status (i.e., an error).
set -o errexit
# ensures that if any command in a pipeline fails, the whole pipeline fails.
set -o pipefail
# ensures that any attempts to use an undefined variable will cause the script to exit.
set -o nounset
# useful for debugging, print each command before executing it.
set -o xtrace


# checking Health of dependent services
postgres_ready() {
    python << END
import sys

from psycopg2 import connect
from psycopg2.errors import OperationalError

try:
    connect(
        dbname="${POSTGRES_DB}",
        user="${POSTGRES_USER}",
        password="${POSTGRES_PASSWORD}",
        host="${POSTGRES_HOST}",
        port="${POSTGRES_PORT}",
    )
except OperationalError:
    sys.exit(-1)
END
}

until postgres_ready; do
  >&2 echo "Waiting for PostgreSQL to become available..."
  sleep 5
done
>&2 echo "PostgreSQL is available"


# redis_ready() {
#     python << END
# import sys

# from redis import Redis
# from redis import RedisError


# try:
#     redis = Redis.from_url("${CELERY_BROKER_URL}", db=0)
#     redis.ping()
# except RedisError:
#     sys.exit(-1)
# END
# }

# until redis_ready; do
#   >&2 echo "Waiting for Redis to become available..."
#   sleep 5
# done
# >&2 echo "Redis is available"

# Idempotent Django commands
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations 
python3 manage.py makemigrations blog
python3 manage.py migrate

exec "$@"