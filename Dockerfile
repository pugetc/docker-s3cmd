FROM alpine:3.3

RUN apk update
RUN apk add python py-pip py-setuptools git ca-certificates
RUN pip install python-dateutil

RUN git clone https://github.com/s3tools/s3cmd.git /opt/s3cmd
RUN ln -s /opt/s3cmd/s3cmd /usr/bin/s3cmd

RUN apk add --no-cache mysql-client

ADD s3cfg /opt/.s3cfg
ADD run.sh /opt/run.sh

# Folders for s3cmd
RUN mkdir /opt/src
RUN mkdir /opt/dest

# Add permissions
RUN chmod -R 777 /opt

WORKDIR /opt

#CMD ["/bin/sh"]
ENTRYPOINT ["/opt/run.sh"]
