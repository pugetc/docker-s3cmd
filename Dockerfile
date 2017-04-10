FROM centos/python-27-centos7

USER root

RUN yum install mysql

RUN git clone https://github.com/s3tools/s3cmd.git /opt/s3cmd
RUN ln -s /opt/s3cmd/s3cmd /usr/bin/s3cmd

ADD s3cfg /opt
ADD run.sh /opt
ADD cleanup.sh /opt

# Folders for s3cmd
RUN mkdir /opt/src
RUN mkdir /opt/dest

# Add permissions
RUN chmod -R 777 /opt
RUN chmod 777 /usr/bin/oc
RUN chgrp -R 0 /usr/bin && chmod -R g+rwX /usr/bin

WORKDIR /opt

CMD ["/opt/run.sh"]
