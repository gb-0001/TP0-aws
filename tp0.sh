#!/bin/bash

# date du jour
backupdate=$(date +%Y-%m-%d)

#répertoire de backup
dirbackup=/home/vagrant/backup-$backupdate

# création du répertoire de backup
/bin/mkdir $dirbackup

# sauvegarde de /home
tar czvf $dirbackup/home-$backupdate.tar.gz -P /home/vagrant/test.txt
tar czvf $dirbackup/home-$backupdate-test1.tar.gz -P /home/vagrant/test1.txt
FULLPATHSRC1=$dirbackup/home-$backupdate.tar.gz
FULLPATHSRC2=$dirbackup/home-$backupdate-test1.tar.gz

#PATH AWSBIN
AWSBIN=/usr/local/bin/aws

BUCKETNAME=bkttpgb0001

#test si le bucket exist et AWS creation du bucket
$AWSBIN s3 ls | grep $BUCKETNAME
if [ $? = 1 ]; then
  $AWSBIN s3 mb s3://bkttpgb0001
fi

#AWS UP du fichier
$AWSBIN s3 cp $FULLPATHSRC1 s3://bkttpgb0001/home-$backupdate.tar.gz
$AWSBIN s3 cp $FULLPATHSRC2 s3://bkttpgb0001/home-$backupdate-test1.tar.gz

#test si cycle de vie du fichier de + de 7j en position
$AWSBIN s3api get-bucket-lifecycle --bucket $BUCKETNAME
if [ $? = 1 ]; then
$AWSBIN s3api put-bucket-lifecycle --bucket $BUCKETNAME --lifecycle-configuration file://s3ruledel.json
fi


#suppresion + de 7j
#find S3PATH/*..tar.gz -mtime +7|xargs rm -f {} ;