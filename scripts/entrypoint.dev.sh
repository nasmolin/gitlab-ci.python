#!/bin/sh

if [ -z "$DJANGO_SECRET_KEY" ]; then
  echo "Error: DJANGO_SECRET_KEY is not set!"
  exit 1
fi

echo "$DJANGO_SECRET_KEY" > /app/.DJANGO_SECRET_KEY

mkdir /app/staticfiles
python manage.py collectstatic --noinput

exec "$@"