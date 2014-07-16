##
## LOCAL DJANGO SETTINGS
##

##
## IMPORTANT SETTINGS
##

# If True, errors will be presented to the user in the browser, and all queries
# will be stored in memory -- so don't leave the server running for too long
# with DEBUG enabled.
#
# If False, errors will be emailed to you (using ADMINS, below).
DEBUG = True

# If True, enable the django-debug-toolbar
DEBUG_TOOLBAR = False

# if True, the site is running over SSL (i.e. https://...)
ENABLE_SSL = False

# If True, enable caching with memcached.  If False, rebuild every page on
# every pageload.  Note that if you modify static files (css, js, less, etc),
# you still need to run ./scripts/files_changed.py
ENABLE_CACHING = True

# Middlewhere caching: cache all pages for anonymous users (not signed in).
CACHE_MIDDLEWARE_ENABLE = ENABLE_CACHING
# Amount of time to cache pages for users who are not logged in
CACHE_MIDDLEWARE_SECONDS = 300

# If True, cache js/css offline.  Note that you will need to run
#  ./manage.py compress
# after every js/css/template change if enabled.
COMPRESS_OFFLINE = False

# Server name
SERVER_NAME = 'SERVER_NAME'
SERVER_IP = 'SERVER_IP'
SITE_URL = ('https://' if ENABLE_SSL else 'http://') + SERVER_NAME

# A list of strings representing the host/domain names that this Django site
# can serve.
ALLOWED_HOSTS = [SERVER_NAME, 'www.%s' % SERVER_NAME]

# Set to True if you are testing and don't want to use a worker node,
# and want to run all tasks synchronously
CELERY_ALWAYS_EAGER = False

##
## AWS S3 CONFIG
##

# AWS S3 keys
AWS_ACCESS_KEY_ID = u''
AWS_SECRET_ACCESS_KEY = u''
AWS_STORAGE_BUCKET_NAME = u''
AWS_S3_SECURE_URLS = ENABLE_SSL
AWS_S3_URL_PROTOCOL = 'https:' if ENABLE_SSL else 'http:'

# Uncomment if using CloudFront with S3, e.g. '<subdomain here>.cloudfront.net'
#AWS_S3_CUSTOM_DOMAIN = u''

# If True, media files are stored on S3 instead of locally
if AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY and AWS_STORAGE_BUCKET_NAME:
    S3_ENABLE = True
else:
    S3_ENABLE = False

# If False, prevent modification of S3 files (useful for debug server clones)
# (auto-generated thumbnails can still be written)
S3_ENABLE_WRITE = False

##
## OTHER SETTTINGS
##

# Important to put a valid email
ADMINS = (
    ('ADMIN_NAME', 'ADMIN_EMAIL'),
)

# Time zone choices: http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
TIME_ZONE = 'TIME_ZONE'

# Locaion of files
DATA_DIR = 'DATA_DIR'

# IP addresses that are allowed to access django-debug-toolbar.
# If your debug server is not local, put your machine's IP here.
INTERNAL_IPS = ('127.0.0.1',)

##
## PASSWORDS (set up automagically by the installer)
##

SECRET_KEY = 'SECRET_KEY'
DATABASES = {
    'default': {
        'NAME': 'DB_NAME',
        'USER': 'DB_USER',
        'PASSWORD': 'DB_PASS',
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'HOST': '',
        'PORT': 'DB_PORT',
        'CONN_MAX_AGE': 0 if DEBUG else 600,

    }
}
