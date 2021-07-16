#!/bin/bash

currentpath=`dirname $0`
if [ ${currentpath} == '.' ];then
  currentpath=`pwd`
fi

backup_path=/backup/db
suffix=`date "+%F"`
logfile=${currentpath}/logs/mysqlbacklog.log

mysql_user=root
mysql_password=UuopkenpDHiHWg
mysqldump_prog=/usr/local/mysql/bin/mysqldump
mysql_sock=/tmp/mysql.sock 

[ ! -d ${backup_path} ] && mkdir -p ${backup_path}
[ ! -d ${currentpath}/logs ] && mkdir -p ${currentpath}/logs

echo "==============================================" >> ${logfile}
echo "`date "+%F %H:%M:%S"` 开始备份MySQL数据"  >> ${logfile}
cd ${backup_path}
${mysqldump_prog} -u${mysql_user} -p${mysql_password} -S ${mysql_sock} -A -B --single-transaction -F --master-data=2 -E -R --triggers |gzip >${backup_path}/all-${suffix}.sql.gz
if [ $? -ne 0 ];then
  echo "`date  "+%F %H:%M:%S"` 备份MySQL数据失败"  >> ${logfile}
else
  echo "`date  "+%F %H:%M:%S"` 备份MySQL数据成功,备份文件名:${backup_path}/all-${suffix}.sql.gz"  >> ${logfile}
fi
echo "`date "+%F %H:%M:%S"` MySQL数据备份结束"  >> ${logfile}
echo "==============================================" >> ${logfile}

cd ${backup_path}
find ${backup_path} -mtime +5 -exec rm -f {} \;  # 删除五天以前的备份数据
