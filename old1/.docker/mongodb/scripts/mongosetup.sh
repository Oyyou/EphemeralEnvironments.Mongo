#!/bin/bash

MONGODB1=ee.mongo

echo "**********************************************" ${MONGODB1}
echo "Waiting for startup.."
sleep 30
echo "done"

echo SETUP.sh time now: `date +"%T" `
mongo --host ${MONGODB1}:27777 -u ${MONGO_INITDB_ROOT_USERNAME} -p ${MONGO_INITDB_ROOT_PASSWORD} <<EOF
var cfg = {
    "_id": "rs0",
    "protocolVersion": 1,
    "version": 1,
    "members": [
        {
            "_id": 0,
            "host": "${MONGODB1}:27777",
            "priority": 2
        },
    ]
};
rs.initiate(cfg, { force: true });
rs.secondaryOk();
db.getMongo().setReadPref('primary');
rs.status();
EOF
