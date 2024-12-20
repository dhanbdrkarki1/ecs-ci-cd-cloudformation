from .base import *
from socket import gethostbyname
from socket import gethostname

DEBUG = os.environ.get("DEBUG_STATUS")

SECRET_KEY = os.environ.get("DJANGO_SECRET_KEY")

# ALLOWED_HOSTS = os.environ.get("ALLOWED_HOSTS").split(",")
# ALLOWED_HOSTS.append(gethostbyname(gethostname()))

ALLOWED_HOSTS = ["*"]

TIME_ZONE = 'Asia/Kathmandu'

# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.humanize',
    'blog',
    'taggit',
    'django.contrib.sites',
    'django.contrib.sitemaps',
    'django.contrib.postgres',
    'django_social_share',
    'storages', # for S3 static files
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    # removed whitenoise
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

TIME_ZONE = 'Asia/Kathmandu'

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'static'

MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# # AWS S3 settings
# if os.environ.get('AWS_ACCESS_KEY_ID') or os.environ.get('AWS_SECRET_ACCESS_KEY'):
#     AWS_ACCESS_KEY_ID = os.environ.get('AWS_ACCESS_KEY_ID')
#     AWS_SECRET_ACCESS_KEY = os.environ.get('AWS_SECRET_ACCESS_KEY')
# AWS_STORAGE_BUCKET_NAME = os.environ.get('AWS_STORAGE_BUCKET_NAME')
# AWS_S3_REGION_NAME = os.environ.get('AWS_S3_REGION_NAME')
# AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'
# AWS_S3_FILE_OVERWRITE = False
# # S3 Security Settings
# AWS_DEFAULT_ACL = None  # Don't override file permissions
# AWS_S3_OBJECT_PARAMETERS = {
#     'CacheControl': 'max-age=86400',  # 24 hours cache
# }

# # Storage os.environ.geturation
# STORAGES = {
#     # Media files storage (user uploads)
#     'default': {
#         'BACKEND': 'storages.backends.s3.S3Storage',
#         'OPTIONS': {
#             'bucket_name': AWS_STORAGE_BUCKET_NAME,
#             'custom_domain': AWS_S3_CUSTOM_DOMAIN,
#             'location': 'media',  # Store media files in /media/ directory
#             'file_overwrite': False,  # Don't overwrite files with same name
#         },
#     },
#     # Static files storage
#     'staticfiles': {
#         'BACKEND': 'storages.backends.s3.S3StaticStorage',
#         'OPTIONS': {
#             'bucket_name': AWS_STORAGE_BUCKET_NAME,
#             'custom_domain': AWS_S3_CUSTOM_DOMAIN,
#             'location': 'static',  # Store static files in /static/ directory
#         },
#     },
# }

# # CORS headers for font files
# AWS_HEADERS = {
#     'Access-Control-Allow-Origin': '*'
# }

# # URLs for static and media files
# STATIC_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/static/'
# MEDIA_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/media/'

# # tell Django where to look for static files
# STATICFILES_DIRS = [
#     os.path.join(BASE_DIR, 'static'),
# ]