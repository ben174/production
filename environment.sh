

docker volume create --name postgres-data
docker volume create --name angrates-static



# delete volumes? 



docker run -d --name=postgres -v postgres-data:/var/lib/postgresql/data postgres:latest


docker exec -i -t postgres createdb -U postgres angrates


docker build -t angrates /opt/apps/angrates/

docker run -d --name=angrates -v static:/usr/src/app/static_root --link=postgres -p 8000:8000 angrates

docker exec -i -t angrates /usr/src/app/manage.py collectstatic --noinput
docker exec -i -t angrates /usr/src/app/manage.py migrate
docker exec -i -t angrates /usr/src/app/manage.py refresh
docker exec -i -t angrates /usr/src/app/manage.py restore

createdb -U postgres angrates

docker build -t nginx /opt/apps/production/nginx
