FROM mongo:4.2

COPY init-mongo.sh /docker-entrypoint-initdb.d/init-mongo.sh
