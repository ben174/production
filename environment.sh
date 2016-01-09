#!/usr/bin/env bash

# postgres
docker volume create --name postgres-data
docker run -d --name=postgres -v postgres-data:/var/lib/postgresql/data postgres:latest


# angrates
docker build -t angrates /opt/apps/angrates/
docker volume create --name angrates-static
docker exec -i -t postgres createdb -U postgres angrates
docker run -d --name=angrates -v angrates-static:/usr/src/app/static_root --link=postgres -p 8000:8000 -e DB_NAME=angrates -e DB_USER=postgres -e DB_PASS=postgres -e DB_SERVICE=postgres -e DB_PORT=5432 angrates

docker exec -i -t angrates /usr/src/app/manage.py collectstatic --noinput
docker exec -i -t angrates /usr/src/app/manage.py migrate
docker exec -i -t angrates /usr/src/app/manage.py refresh
docker exec -i -t angrates /usr/src/app/manage.py restore


# bugben
docker build -t bugben /opt/apps/bugben/
docker volume create --name bugben-static
docker exec -i -t postgres createdb -U postgres bugben
docker run -d --name=bugben -v bugben-static:/usr/src/app/static_root --link postgres -p 8001:8000 -e DB_NAME=bugben -e DB_USER=postgres -e DB_PASS=postgres -e DB_SERVICE=postgres -e DB_PORT=5432 bugben
docker exec -i -t bugben /usr/src/app/manage.py collectstatic --noinput
docker exec -i -t bugben /usr/src/app/manage.py migrate
docker exec -i -t bugben /usr/src/app/manage.py provision


# nginx
docker build -t nginx /opt/apps/production/nginx
docker run -d --name=nginx --link=angrates --link=bugben -v bugben-static:/static/bugben -v angrates-static:/static/angrates -p 80:80 nginx
