from mongo:3

VOLUME ["/app", "/secrets"]

COPY setup.sh /setup.sh
RUN chmod +x setup.sh

RUN apt-get update && apt-get install -y --no-install-recommends python-pip
RUN pip install awscli

ENV AWS_DEFAULT_REGION=eu-west-1
ENV AWS_S3_BUCKET_NAME=turistforeningen
ENV AWS_S3_BUCKET_PATH=/backups/mongo/

CMD ["/bin/true"]
