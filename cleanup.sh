#!/bin/sh
set -e

s3cleanup()
{

s3cmd ls $1 | grep " DIR " -v | while read -r line;
  do
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d "$createDate" +%s`
    olderThan=`date -d "-${CONFIG_rotation_remote} days" +%s`
    if [[ $createDate -lt $olderThan ]]
      then
        fileName=`echo $line|awk {'print $4'}`
        if [[ $fileName != "" ]]
          then
            printf 'Deleting "%s"\n' $fileName
            s3cmd del "$fileName"
          else
            printf "\n No files to delete. Bucket ${CONFIG_backup_dir_remote} directory is empty."
        fi
      else
           fileName=`echo $line|awk {'print $4'}`
           printf "\n Retention date has not been reached for $fileName"
    fi
  done;
printf "\n\n"

}

s3cleanup ${s3_host_bucket}/${MYSQL_DATABASE}/ ${MYSQLDUMP_HISTORY_LIMIT}
