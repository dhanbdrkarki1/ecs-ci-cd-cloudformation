# Stage 1: Build stage
FROM python:3.12-alpine AS builder

# ensures that the Python interpreter doesn’t generate .pyc
ENV PYTHONDONTWRITEBYTECODE=1
# send python output to the terminal without being buffered in real-time
ENV PYTHONUNBUFFERED=1

# Working directory
WORKDIR /usr/src/app

# Define build arguments for user and group names and IDs
ARG USER_NAME=test
ARG GROUP_NAME=test
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps \
    gcc musl-dev python3-dev \
    # for psycopg2-binary package installation
    && apk add postgresql-dev \
    # Install Pillow dependencies and other system libraries
    && apk add jpeg-dev zlib-dev libjpeg \
    # Install uWSGI dependencies
    && apk add build-base linux-headers pcre-dev \
    # Upgrade pip
    && python3 -m pip install --upgrade pip

# Create a group and user with specified names and IDs
RUN addgroup -g ${USER_GID} ${GROUP_NAME} && \
    adduser -u ${USER_UID} -G ${GROUP_NAME} -S -h /home/${USER_NAME} ${USER_NAME}

# Copy and install Python dependencies
COPY --chown=${USER_NAME}:${GROUP_NAME} ./requirements.txt /usr/src/app/
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime stage
FROM python:3.12-alpine
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Working directory
WORKDIR /usr/src/app

# Define build arguments for user and group names and IDs
ARG USER_NAME=test
ARG GROUP_NAME=test
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV DJANGO_SETTINGS_MODULE=blogsite.settings

# Install runtime dependencies (excluding build tools)
RUN apk add --no-cache postgresql-libs libjpeg libpng pcre curl bash dos2unix

# Re-create the user in the runtime stage
RUN addgroup -g ${USER_GID} ${GROUP_NAME} && \
    adduser -u ${USER_UID} -G ${GROUP_NAME} -S -h /home/${USER_NAME} ${USER_NAME}

# Copy installed Python packages and binaries from the build stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the application code
COPY --chown=${USER_NAME}:${GROUP_NAME} . .

# Ensure the script has correct line endings and is executable
RUN dos2unix entrypoint.sh && \
    chmod +x entrypoint.sh

# Use the non-root user to run the app
USER ${USER_NAME}:${GROUP_NAME}

# Expose the port
EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Set the entry point to your script
# ENTRYPOINT ["./entrypoint.sh"]

# Dev Server
# The CMD will be passed as arguments to the ENTRYPOINT script
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# uWSGI Server
# The CMD will now start uWSGI
# CMD ["uwsgi", "--ini", "uwsgi.ini"]