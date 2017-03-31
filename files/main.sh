#!/bin/sh -xe

#
# main entry point to run s3cmd
#
S3CMD_PATH=/opt/s3cmd/s3cmd

#
# Check for required parameters
#
if [ -z "${aws_key}" ]; then
    echo "ERROR: The environment variable key is not set."
    exit 1
fi

if [ -z "${aws_secret}" ]; then
    echo "ERROR: The environment variable secret is not set."
    exit 1
fi

if [ -z "${cmd}" ]; then
    echo "ERROR: The environment variable cmd is not set."
    exit 1
fi

#
# Replace key and secret in the /.s3cfg file with the one the user provided
#
echo "" >> /opt/.s3cfg
echo "access_key=${aws_key}" >> /opt/.s3cfg
echo "secret_key=${aws_secret}" >> /opt/.s3cfg

#
# Add region base host
#
echo "host_base = ${s3_host_base}" >> /opt/.s3cfg

${S3CMD_PATH} ls

#
# Finished operations
#
echo "Finished s3cmd operations"
