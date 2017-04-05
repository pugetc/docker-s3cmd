#!/bin/sh
set -e

echo "access_key = ${aws_key}" >> /opt/.s3cfg
echo "secret_key = ${aws_secret}" >> /opt/.s3cfg
echo "host_base = ${s3_host_base}" >> /opt/.s3cfg
echo "host_bucket = ${s3_host_bucket}" >> /opt/.s3cfg
echo "use_https = ${s3_host_use_https}" >> /opt/.s3cfg

######################################################################################################

s3cleanup()
{

s3cmd ls $1 | grep " DIR " -v | while read -r line;
  do
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d "$createDate" +%s`
    olderThan=`date -d "-${MYSQLDUMP_HISTORY_LIMIT} days" +%s`
    if [[ $createDate -lt $olderThan ]]
      then
        fileName=`echo $line|awk {'print $4'}`
        if [[ $fileName != "" ]]
          then
            printf 'Deleting "%s"\n' $fileName
            s3cmd del "$fileName"
          else
            printf "\n No files to delete. Bucket's ${MYSQL_DATABASE} directory is empty."
        fi
      else
           fileName=`echo $line|awk {'print $4'}`
           printf "\n Retention date has not been reached for $fileName"
    fi
  done;
printf "\n\n"

}

mysqlbackup()
{

echo "Starting the new MySQL DB dump locally ..."
mkdir -p ${MYSQLDUMP_DIRECTORY}/${MYSQL_DATABASE}
mysqldump --host=${MYSQL_SERVICE_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE} | gzip > ${MYSQLDUMP_DIRECTORY}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_$(date +'%Y%m%d_%H%M').sql.gz
echo "DB dump finished."
echo "Starting the cleanup of old dump files ..."
cd ${MYSQLDUMP_DIRECTORY}/${MYSQL_DATABASE}
(ls -t ${MYSQL_DATABASE}_*.sql.gz|head -n ${MYSQLDUMP_HISTORY_LIMIT};ls ${MYSQL_DATABASE}_*.sql.gz)|sort|uniq -u|sed -e 's,.*,\"&\",g'|xargs -r rm
echo "Cleanup finished."

}

s3backup()
{

echo "Uploading the new backup to OBOS..."
s3cmd put -f ${MYSQLDUMP_DIRECTORY}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_$(date +'%Y%m%d_%H%M').sql.gz ${s3_host_bucket}/${MYSQL_DATABASE}/${MYSQL_DATABASE}_$(date +'%Y%m%d_%H%M').sql.gz
echo "New backup uploaded."

echo "Removing old backup ..."
s3cleanup ${s3_host_bucket}/${MYSQL_DATABASE}/ ${MYSQLDUMP_HISTORY_LIMIT}
echo "Old backup removed."

}

######################################################################################################

echo "MySQL DB Backup to OBOS started ..."
mysqlbackup
s3backup
echo "Backup to OBOS completed."
