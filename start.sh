docker-compose -f ./docker-compose.yaml down
mkdir -pv volume/svnrepo
chmod -Rfv 777 volume/svnrepo
docker-compose -f ./docker-compose.yaml build --force-rm --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) && \
docker-compose -f ./docker-compose.yaml up -d
