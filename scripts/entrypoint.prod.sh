#!/bin/sh

mkdir /app/staticfiles
python manage.py collectstatic --noinput

exec "$@"