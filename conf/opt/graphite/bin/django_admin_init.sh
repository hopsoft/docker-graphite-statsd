#!/bin/sh

BIN=/opt/graphite/bin/python3
[[ -f "/opt/graphite/bin/pypy3" ]] && BIN=/opt/graphite/bin/pypy3

cat <<EOF | ${BIN} /opt/graphite/bin/django-admin.py shell
from django.contrib.auth import get_user_model

User = get_user_model()  # get the currently active user model

User.objects.filter(username='root').exists() or \
    User.objects.create_superuser('root', 'root.graphite@mailinator.com', 'root')
EOF