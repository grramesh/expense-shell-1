#!/bin/bash
source ./common.sh

check_root  # to call check_root from other script, it has to be in function

echo "please enter db password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$LOGFILE
#VALIDATE $?"disable default nodejs"
dnf module enable nodejs:20 -y &>>$LOGFILE
#VALIDATE $? "enable nodejs"
dnf install nodejs -y     &>>$LOGFILE
#VALIDATE $? "installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
 then 
  useradd expense &>>$LOGFILE
#VALIDATE $? "Creating expense user"
else 
  echo -e "expense user already created ..$Y SKIIPING $N"
 fi

 mkdir -p /app &>>$LOGFILE    # -p is added additionally , if there is no directory then it makes directory if not it becomes silent
 #VALIDATE $? "creating app directory"
 curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
 #VALIDATE $? "Downloading backend code"

 cd /app &>>$LOGFILE
 rm -rf /app/* # here /* is directory with files . (before scenerio--> sudo su -->cd /app ->unzip /tmp/backend.zip --> error appeared due to it was asking to override the file)
 unzip /tmp/backend.zip &>>$LOGFILE
 #VALIDATE $? "Extracted backend code"

 npm install &>>$LOGFILE
 #VALIDATE $? "Installing nodejs dependencies"
 # shell scripting cannot use vim --> that is for humans 
 # hence created backend.serive and copying from it and pasting here
 #check your repo and path
 cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service  &>>$LOGFILE
 #VALIDATE $? "copied backend service"

 systemctl daemon-reload &>>$LOGFILE
 #VALIDATE $? "daemon reload"

 systemctl start backend &>>$LOGFILE
 #VALIDATE $? "start backend"

 systemctl enable backend &>>$LOGFILE
 #VALIDATE $? "enable backend"

 dnf install mysql -y  &>>$LOGFILE
 #VALIDATE $? "Installing mysql client"

 mysql -h db.rishvihaan.store -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
 #VALIDATE $? "schema loading"  #at last checking whether it is repeting --> sudo cat /app/schema/backend.sql (anyhow it is idempotency)


 systemctl restart backend &>>$LOGFILE
 #SVALIDATE $? "Restarting backend"

# at last whether system is running or not --> netstat -lntp ---> systemctl status backend

