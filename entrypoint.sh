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

# # Debug: Print current directory and list contents
# echo "Current directory: $(pwd)"
# ls -la

# # Ensure the directory exists
# if [ ! -d "/usr/src/app" ]; then
#     echo "Error: Directory /usr/src/app does not exist"
#     exit 1
# fi

# Show Django version and settings
log_debug "Django version:"
python3 -m django --version
log_debug "Using settings module: ${DJANGO_SETTINGS_MODULE}"

# checking Health of dependent services
check_database_connection() {
    if [ -z "$DB_ENGINE" ]; then
        echo "Error: DB_ENGINE is not set. Please set it to 'mysql' or 'postgresql'."
        exit 1
    fi

    if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
        echo "Error: One or more database environment variables (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD) are not set."
        exit 1
    fi

    echo "Attempting to connect to $DB_ENGINE database at $DB_HOST:$DB_PORT..."

    if [ "$DB_ENGINE" = "django.db.backends.postgresql" ]; then
        python << END
import sys
import psycopg2
try:
    conn = psycopg2.connect(
        dbname="${DB_NAME}",
        user="${DB_USER}",
        password="${DB_PASSWORD}",
        host="${DB_HOST}",
        port="${DB_PORT}",
        connect_timeout=10
    )
    conn.close()
    print("PostgreSQL connection successful!")
except Exception as e:
    print(f"PostgreSQL connection failed: {str(e)}", file=sys.stderr)
    sys.exit(-1)
END
    elif [ "$DB_ENGINE" = "django.db.backends.mysql" ]; then
        python << END
import sys
import pymysql
try:
    conn = pymysql.connect(
        database="${DB_NAME}",
        user="${DB_USER}",
        password="${DB_PASSWORD}",
        host="${DB_HOST}",
        port=int("${DB_PORT}"),
        connect_timeout=10
    )
    conn.close()
    print("MySQL connection successful!")
except Exception as e:
    print(f"MySQL connection failed: {str(e)}", file=sys.stderr)
    sys.exit(-1)
END
    else
        echo "Error: Unsupported DB_ENGINE. Please set it to 'mysql' or 'postgresql'."
        exit 1
    fi
}


# Add maximum retry attempts
MAX_RETRIES=30
RETRY_COUNT=0

# Wait for PostgreSQL with a timeout
log_info "Waiting for Database to become available..."

until check_database_connection; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        log_error "Failed to connect to database after $MAX_RETRIES attempts. Exiting..."
        exit 1
    fi
    log_info "Database is unavailable - sleeping for 5 seconds (Attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 5
done

log_info "Database is available"


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
