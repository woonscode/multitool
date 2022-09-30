#!/bin/bash
set -e
for i in `seq 5001 5050`
do
    ssh ubuntu@$INSTANCE_URL "mkdir -p loadtest/$i && exit"
    scp ./$APP_DIR/$ARTEFACT_ID.$ARTEFACT_PACKAGE ubuntu@$INSTANCE_URL:/home/ubuntu/loadtest/$i
    ssh ubuntu@$INSTANCE_URL "export NAME=$NAME && export COLOR=$COLOR && export PORT=$i && unzip -o -qq -d loadtest/$i/$UNZIPPED_DIR loadtest/$i/$ARTEFACT_ID.$ARTEFACT_PACKAGE && cd loadtest/$i/$UNZIPPED_DIR && . ./deploy.sh && echo "python3 ./loadtest/$i/$UNZIPPED_DIR/app.py" | at now && exit"
done