source /secrets/aws.env

# Clear dump dir
# rm -rf /dump/*

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

mongo --host mongo-01 --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'mongo-01'}]})"

mongorestore --host mongo-01 --drop

mongo --host mongo-01 --eval "rs.add('mongo-02')"
mongo --host mongo-01 --eval "rs.addArb('mongo-03')"
