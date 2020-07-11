#!/bin/sh

cat <<EOF | python3 /opt/graphite/bin/django-admin.py shell
from django.contrib.auth import get_user_model

User = get_user_model()  # get the currently active user model

User.objects.filter(username='root').exists() or \
    User.objects.create_superuser('root', 'root.graphite@mailinator.com', 'root')
EOF