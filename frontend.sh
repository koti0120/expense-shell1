#!/bin/bah
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# echo "Please enter db password:"
# read -s mysql_root_password
VALIDATE(){
    if [ $1 -ne 0 ]
    then
      echo -e "$2 is $R FAILED $N"
      exit 1
    else
      echo -e "$2 is $G SUCCESS $N"
    fi
}
if [ $USERID -ne 0 ]
then
  echo "Please run this script with root user"
  exit 1
else
  echo "you are now super user"
fi

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "delete default nginx file"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "download frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip frontend code"

cp /home/ec2-user/expense-shell1/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE "copied front end code" 

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart nginx"

