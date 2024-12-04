"""
WSGI config for blogsite project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/3.2/howto/deployment/wsgi/
"""

# monitoring using new relic
# import newrelic.agent 
# newrelic.agent.initialize('newrelic.ini') 
# newrelic.agent.register_application() 

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'blogsite.settings')

application = get_wsgi_application()