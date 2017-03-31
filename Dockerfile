FROM alpine:3.3

RUN apk update
RUN apk add python py-pip py-setuptools git ca-certificates
RUN pip install python-dateutil

RUN git clone https://github.com/s3tools/s3cmd.git /opt/s3cmd
RUN ln -s /opt/s3cmd/s3cmd /usr/bin/s3cmd

WORKDIR /opt

ADD ./files/s3cfg /opt/.s3cfg
ADD ./files/main.sh /opt/main.sh

# Folders for s3cmd
RUN mkdir /opt/src
RUN mkdir /opt/dest

WORKDIR /

# Add permissions
RUN chmod -R 777 /

CMD ["/opt/main.sh"]
