#!/bin/bash
# Django 1.11
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py makemigrations --settings=graphite.settings
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py migrate auth --settings=graphite.settings
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py migrate --run-syncdb --settings=graphite.settings
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py createsuperuser --settings=graphite.settings

# Django 1.8
# PYTHONPATH=/opt/graphite/webapp django-admin.py syncdb --settings=graphite.settings
# Django 1.6
# PYTHONPATH=/opt/graphite/webapp django-admin.py update_users --settings=graphite.settings
