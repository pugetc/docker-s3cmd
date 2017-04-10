#!/bin/sh
set -e

export KUBECONFIG=/tmp/.kube

s3cleanup()
{

s3cmd ls $1 | grep " DIR " -v | while read -r line;
  do
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d "$createDate" +%s`
    olderThan=`date -d "-$2 days" +%s`
    if [[ $createDate -lt $olderThan ]]
      then
        fileName=`echo $line|awk {'print $4'}`
        if [[ $fileName != "" ]]
          then
            printf 'Deleting "%s"\n' $fileName
            s3cmd del "$fileName"
          else
            printf "\n No files to delete. Bucket's $1 directory is empty."
        fi
      else
           fileName=`echo $line|awk {'print $4'}`
           printf "\n Retention date has not been reached for $fileName"
    fi
  done;
printf "\n\n"

}

jobcleanup()
{

oc login https://$KUBERNETES_PORT_443_TCP_ADDR:$KUBERNETES_SERVICE_PORT_HTTPS \
  --token `cat /var/run/secrets/kubernetes.io/serviceaccount/token` \
  --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  
oc get jobs -n $1 | grep $2 > /tmp/jobs

while read JOB_WITH_STATS
do
    JOB_NAME=$(eval echo "${JOB_WITH_STATS}" | awk '{print $1}')
    SUCCESSFUL_RUN=$(eval echo "${JOB_WITH_STATS}" | awk '{print $3}')

    if [ ${SUCCESSFUL_RUN} == "1" ]; then
    
            echo "Deleting old job ${JOB_NAME} !"
            oc delete job ${JOB_NAME} -n $1

    else
      echo "\"${JOB_NAME}\" not ended yet!"
    fi
done < /tmp/jobs

}

s3cleanup ${s3_host_bucket}/${MYSQL_DATABASE}/ ${MYSQLDUMP_HISTORY_LIMIT}

jobcleanup ${PROJECT_NAME} ${APPLICATION_NAME}
