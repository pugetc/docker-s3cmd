#!/bin/sh
set -e

echo "" >> /opt/.s3cfg
echo "access_key = ${aws_key}" >> /opt/.s3cfg
echo "secret_key = ${aws_secret}" >> /opt/.s3cfg
echo "host_base = ${s3_host_base}" >> /opt/.s3cfg
echo "host_bucket = ${s3_host_bucket}" >> /opt/.s3cfg

exec tail -f /dev/null
