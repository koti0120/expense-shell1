#!/bin/bah
source ./common.sh
check_root

dnf install nginx -y &>>$LOG_FILE
# VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
# VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
# VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
# VALIDATE $? "delete default nginx file"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
# VALIDATE $? "download frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE
# VALIDATE $? "unzip frontend code"

cp /home/ec2-user/expense-shell1/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
# VALIDATE "copied front end code" 

systemctl restart nginx &>>$LOG_FILE
# VALIDATE $? "restart nginx"

