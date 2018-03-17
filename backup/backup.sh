#!/bin/bash

#Funcion: backup archives and mysql database
#Author: takashiki
#Website: http://blog.skyx.in

#IMPORTANT!!!Please Setting the following Values!

readonly EXPIRED_DAYS=3
readonly BACKUP_HOME="/backup/"
readonly MYSQL_DUMP="/usr/bin/mysqldump"
readonly ENABLE_CLOUD=${ENABLE_CLOUD}
readonly COS="/usr/bin/coscmd"
######~Set Directory you want to backup~######
readonly BACKUP_DIR=(${BACKUP_DIR})
readonly EXCLUDE_DIR=(${EXCLUDE_DIR})

######~Set MySQL Database you want to backup~######
readonly BACKUP_DB=(${BACKUP_DB})

######~Set MySQL UserName and password~######
readonly MYSQL_USER=${MYSQL_USER}
readonly MYSQL_PASSWORD=${MYSQL_PASSWORD}
readonly MYSQL_HOST=mysql
readonly MYSQL_PORT=3306

#Values Setting END!

BACKUP_TIME=$(date +"%Y%m%d%H%M")
CURRENT_BACKUP_HOME=${BACKUP_HOME}${BACKUP_TIME}/
OLD_BACKUP=$(date +"%Y%m%d" --date="${EXPIRED_DAYS} days ago")*
TEMP_FILE=${CURRENT_BACKUP_HOME}${BACKUP_TIME}.tar

function backup_archive()
{
    local backup_path=$1
    local dir_name=`echo ${backup_path##*/}`
    local pre_dir=`echo ${backup_path}|sed 's/'${dir_name}'//g'`
    local exclude=''
    for dir in ${EXCLUDE_DIR[@]};do
       exclude=${exclude}' --exclude='${dir} 
    done
    tar zcf ${CURRENT_BACKUP_HOME}${dir_name}-${BACKUP_TIME}.tar.gz -C ${pre_dir} ${dir_name} ${exclude}
}

function backup_sql()
{
    local dump_file=${CURRENT_BACKUP_HOME}db-$1-${BACKUP_TIME}.sql
    ${MYSQL_DUMP} -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_PASSWORD} $1 > ${dump_file}
    tar zcf ${CURRENT_BACKUP_HOME}db-$1-${BACKUP_TIME}.tar.gz -C ${CURRENT_BACKUP_HOME} ${dump_file##*/}
    /bin/rm -f ${dump_file}
}

function tar_files()
{
    tar cvf ${TEMP_FILE} -C ${CURRENT_BACKUP_HOME} . --exclude=${temp_file##*/}
    echo "tar cvf ${TEMP_FILE} -C ${CURRENT_BACKUP_HOME} *"
}

function cos_upload()
{
    ${COS} upload ${TEMP_FILE} ${BACKUP_TIME}.tar
}

if [ ! -f ${MYSQL_DUMP} ]; then  
    echo "mysqldump command not found.please check your setting."
    exit 1
fi

if [ ! -d ${CURRENT_BACKUP_HOME} ]; then  
    mkdir -p ${CURRENT_BACKUP_HOME}
fi

echo "Backup website files..."
for dd in ${BACKUP_DIR[@]};do
    backup_archive ${dd}
done

echo "Backup Databases..."
for db in ${BACKUP_DB[@]};do
    backup_sql ${db}
done

if [ ${ENABLE_CLOUD} ]; then  
    echo "Upload backup files to cloud..."
    tar_files
    cos_upload
fi

echo "Delete old backup files: ${BACKUP_HOME}${OLD_BACKUP} ..."
rm -rf ${BACKUP_HOME}${OLD_BACKUP}

echo "complete."
