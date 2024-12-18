#!/bin/bah
source ./common.sh
check_root

echo "Please enter db password:"
read -s mysql_root_password

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing mysql-server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enable mysqld"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "start mysqld"

# mysql_secure_installation --set-root-pass mysql_root_password &>>$LOG_FILE
# VALIDATE $? "setting up root password"

mysql -h db.kanakam.top -u root -p${mysql_root_password} -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOG_FILE
    VALIDATE $? "setting up root password"
else
   echo -e "already setting up root password $Y SKIPPING $N"
fi 