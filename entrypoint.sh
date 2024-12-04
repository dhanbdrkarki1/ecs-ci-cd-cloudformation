#!/bin/bash

# ensures that the script exits immediately if any command exits with a non-zero status (i.e., an error).
set -o errexit
# ensures that if any command in a pipeline fails, the whole pipeline fails.
set -o pipefail
# ensures that any attempts to use an undefined variable will cause the script to exit.
set -o nounset
# useful for debugging, print each command before executing it.
set -o xtrace

# Define logging functions
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

log_warn() {
    echo "[WARN] $1" >&2
}

# checking Health of dependent services
postgres_ready() {
    python << END
import sys
import psycopg2
from psycopg2.errors import OperationalError

try:
    psycopg2.connect(
        dbname="${DB_NAME}",
        user="${DB_USER}",
        password="${DB_PASSWORD}",
        host="${DB_HOST}",
        port="${DB_PORT}",
        connect_timeout=5
    )
except OperationalError:
    sys.exit(-1)
END
}

# Handle database migrations
handle_migrations() {
    log_info "Running database migrations..."
    
    # Run makemigrations first
    if ! python3 manage.py makemigrations --noinput; then
        log_error "Failed to make migrations"
        exit 1
    fi
    
    # Then apply migrations
    if ! python3 manage.py migrate --noinput; then
        log_error "Failed to apply migrations"
        exit 1
    fi
    
    log_info "Database migrations completed successfully"
}

# Create superuser if needed
create_superuser() {
    if [ ! -z "$DJANGO_SUPERUSER_USERNAME" ] && [ ! -z "$DJANGO_SUPERUSER_PASSWORD" ] && [ ! -z "$DJANGO_SUPERUSER_EMAIL" ]; then
        log_info "Checking if superuser exists..."
        
        # Check if superuser exists using Django shell
        python3 manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
exists = User.objects.filter(username=\"${DJANGO_SUPERUSER_USERNAME}\").exists()
exit(0 if exists else 1)
"
        
        if [ $? -eq 1 ]; then
            log_info "Creating superuser..."
            python3 manage.py createsuperuser --noinput
            if [ $? -eq 0 ]; then
                log_info "Superuser created successfully"
            else
                log_warn "Failed to create superuser"
            fi
        else
            log_info "Superuser already exists, skipping creation"
        fi
    else
        log_warn "Superuser environment variables not set, skipping superuser creation"
    fi
}

until postgres_ready; do
  >&2 echo "Waiting for PostgreSQL to become available..."
  sleep 5
done
>&2 echo "PostgreSQL is available"

handle_migrations
create_superuser

exec "$@"
