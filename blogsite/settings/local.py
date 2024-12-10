from .base import *

DEBUG = os.environ.get("DEBUG_STATUS")

SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY")

# Parse the ALLOWED_HOSTS from the environment variable
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', '').split(',')

# Ensure the list is clean (e.g., no empty strings)
ALLOWED_HOSTS = [host.strip() for host in ALLOWED_HOSTS if host.strip()]

TIME_ZONE = 'Asia/Kathmandu'

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'static'

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')