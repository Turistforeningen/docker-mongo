#!/bin/bash

source /secrets/aws.env

# Clean dump dir
rm -rf /dump/*

# Clean data dir
rm -rf /data/*

s3_path="s3://${AWS_S3_BUCKET_NAME}${AWS_S3_BUCKET_PATH}"
s3_file=$2
# Default to the latest backup if no argument specified
: ${s3_file:=`aws s3 ls ${s3_path} | tail -n 1 | awk ' {print $4}'`}

echo "Downloading '${s3_file}' from S3..."
aws s3 cp "${s3_path}${s3_file}" /dump/mongo.tar.gz
AWS_STATUS=$?
if [ $AWS_STATUS -ne 0 ]; then
  echo "AWS CLI exited with code $AWS_STATUS; aborting import"
  exit 1
fi

tar -xvzf /dump/mongo.tar.gz

IFS=',' read -r -a MEMBERS <<< "$MONGO_RS_MEMBERS"
IFS=',' read -r -a ARBITERS <<< "$MONGO_RS_ARBITERS"

mongo --host ${MEMBERS[0]} --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: '${MEMBERS[0]}'}]})"

mongorestore --host ${MEMBERS[0]} --drop

for MEMBER in "${MEMBERS[@]:1}"
do
    mongo --host ${MEMBERS[0]} --eval "rs.add('$MEMBER')"
done

for ARBITER in "${ARBITERS[@]}"
do
    mongo --host ${MEMBERS[0]} --eval "rs.addArb('$ARBITER')"
done
