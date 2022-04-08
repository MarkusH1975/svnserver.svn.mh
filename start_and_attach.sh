docker-compose -f ./docker-compose.yaml down
docker-compose -f ./docker-compose.yaml build --force-rm --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) && \
docker-compose -f ./docker-compose.yaml up -d && \
docker attach svnserver.svn
