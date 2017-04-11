FROM python:alpine

RUN git clone https://github.com/s3tools/s3cmd.git /opt/s3cmd
RUN ln -s /opt/s3cmd/s3cmd /usr/bin/s3cmd

RUN apk add --no-cache mysql-client
RUN \
echo http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
apk add --no-cache mongodb-tools

ADD oc /usr/bin/oc

ADD s3cfg /opt/.s3cfg
ADD run.sh /opt/run.sh
ADD cleanup.sh /opt/cleanup.sh

# Folders for s3cmd
RUN mkdir /opt/src
RUN mkdir /opt/dest

# Add permissions
RUN chmod -R 777 /opt
RUN chmod 777 /usr/bin/oc
RUN chgrp -R 0 /usr/bin && chmod -R g+rwX /usr/bin

WORKDIR /opt

CMD ["/opt/run.sh"]
