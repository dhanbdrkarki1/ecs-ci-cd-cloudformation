#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
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

log_debug() {
    echo "[DEBUG] $1"
}

# checking Health of dependent services
postgres_ready() {
    log_debug "Attempting to connect to PostgreSQL at ${DB_HOST}:${DB_PORT}"
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

# Add maximum retry attempts
MAX_RETRIES=30
RETRY_COUNT=0

# Wait for PostgreSQL with a timeout
# log_info "Waiting for PostgreSQL to become available..."
# until postgres_ready; do
#     RETRY_COUNT=$((RETRY_COUNT + 1))
#     if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
#         log_error "Failed to connect to PostgreSQL after $MAX_RETRIES attempts. Exiting..."
#         exit 1
#     fi
#     log_warn "PostgreSQL is unavailable - sleeping for 5 seconds (Attempt $RETRY_COUNT/$MAX_RETRIES)"
#     sleep 5
# done
# log_info "PostgreSQL is available"

# static files handling
handle_static() {
    log_info "Collecting static files..."
    
    if ! python3 manage.py collectstatic --noinput -v 2; then
        log_error "Failed to collect static files"
        exit 1
    fi
    log_info "Static files collected successfully"
}

# Handle database migrations
handle_migrations() {
    log_info "Running database migrations..."
    
    # Run makemigrations first
    if ! python3 manage.py makemigrations blog --noinput; then
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
        
        # Check if superuser exists using a simpler approach
        SUPERUSER_EXISTS=$(python3 manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
print(User.objects.filter(username='${DJANGO_SUPERUSER_USERNAME}').exists())
")
        
        if [ "$SUPERUSER_EXISTS" = "True" ]; then
            log_info "Superuser ${DJANGO_SUPERUSER_USERNAME} already exists"
        else
            log_info "Creating superuser..."
            python3 manage.py createsuperuser --noinput
            log_info "Superuser created successfully"
        fi
    else
        log_warn "Superuser environment variables not set"
    fi
}


handle_static
handle_migrations
create_superuser

exec "$@"
