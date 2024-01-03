#!/bin/bash

set -Eeuo pipefail

# Remove the lock file if it exists
if [ -f /data/db/mongod.lock ]; then
    echo "Removing mongod.lock file..."
    rm /data/db/mongod.lock
fi

echo "User Init Script is entered"
mongo -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin "$MONGO_INITDB_DATABASE" <<EOF
    db.createUser({
        user: '$MONGO_INITDB_USERNAME',
        pwd: '$MONGO_INITDB_PASSWORD',
        roles: [
            { role: "userAdminAnyDatabase", db: '$MONGO_INITDB_DATABASE' },
            { role: "userAdmin", db: '$MONGO_INITDB_DATABASE' },
            { role: "readWrite", db: '$MONGO_INITDB_DATABASE' },
            { role: "dbAdmin", db: '$MONGO_INITDB_DATABASE' },
            { role: "clusterAdmin", db: '$MONGO_INITDB_DATABASE' },
            { role: "readWriteAnyDatabase", db: '$MONGO_INITDB_DATABASE' },
            { role: "dbAdminAnyDatabase", db: '$MONGO_INITDB_DATABASE' },
            { role: "readAnyDatabase", db: '$MONGO_INITDB_DATABASE' }
        ]
    })

    var dbNames = [
        'vibes',
    ];

    var conn = new Mongo();
    admin = conn.getDB( "$MONGO_INITDB_DATABASE" );
    admin.auth( '$MONGO_INITDB_USERNAME', '$MONGO_INITDB_PASSWORD' );
    
    dbNames.forEach(dbName=> {
        var db =  conn.getDB(dbName);
    
        db.createUser({
            user:'$MONGO_INITDB_USERNAME',
            pwd:'$MONGO_INITDB_PASSWORD',
            roles: [{role:'readWrite',db:dbName}]
        })
    });
EOF

# Connect to the vibes database
mongo -u "$MONGO_INITDB_USERNAME" -p "$MONGO_INITDB_PASSWORD" --authenticationDatabase "$MONGO_INITDB_DATABASE" <<EOF
    var db = db.getSiblingDB('vibes');

    db.createUser({
        user: '$MONGO_INITDB_USERNAME',
        pwd: '$MONGO_INITDB_PASSWORD',
        roles: [{ role: 'readWrite', db: 'vibes' }]
    });

    db.createCollection('EventJournal');

    const vibesList = [
        'Chill AF Vibes',
        'Positive Vibes Only (No Negativity Allowed)',
        'Vibing on a Whole New Level',
        'Upbeat and Groovy',
        'Laid-back Like a Sloth in a Hammock',
        'Cozy Blanket Fort Vibes',
        'Good Vibes and Good Times',
        'Mellow Yellow, Dude',
        'Excitement Level: Over 9000',
        'Peace, Love, and Pizza Rolls',
        'Joyful Jamboree',
        'Vibing Harder Than a Dancing Cat',
        'Calm as a Cucumber (With Extra Coolness)',
        'Lively AF and Living Large',
        'Elegance Level: Classy Cat Wearing a Tuxedo',
        'Nostalgia Trip: 90s Kids Edition',
        'Adventures in Flavor Town',
        'Romance Level: Cheesy Rom-Com Marathon',
        'Deep Thoughts, Shallow Pockets',
        'Diverse AF Vibes: Like a Playlist on Shuffle'
    ];

    const currentTime = new Date();

    vibesList.forEach(vibe => {
        db.EventJournal.insertOne({
            payload: {
            type: 'VibeCreated',
            value: vibe,
            timeAdded: currentTime
            }
        });
    });
EOF

echo "User Init Script is finished"