#!/bin/bah
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter db password:"
read -s mysql_root_password
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs"

useradd expense &>>$LOG_FILE
VALIDATE $? "creating user"

mkdir -p /app
VALIDATE $? "creating user"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "download backend code"

cd /app
VALIDATE $? "change app directory"

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "unzip the backend code"

npm install &>>$LOG_FILE
VALIDATE $? "install dependencies"

cp /home/ec2-user/expense-shell1/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "copied backend code"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "reload daemon"

systemctl start backend &>>$LOG_FILE
VALIDATE $? "start backend"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "enable backend"

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "install mysql"

mysql -h db.kanakam.top -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "load the schema"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "restart backend"

