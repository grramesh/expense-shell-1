#!/bin/bash
source ./common.sh


check_root  # to call check_root from other script, it has to be in function

echo "please enter db password:"
read -s mysql_root_password

dnf install mysql-server1233 -y &>>$LOGFILE
#VALIDATE $? "Installing mysql server"

systemctl enable mysqld  &>>$LOGFILE
#VALIDATE $? "enabling mysql"

systemctl start mysqld &>>$LOGFILE
#VALIDATE $? "starting mysql"

# mysql -hdb.rishvihaan.store -uroot -pExpenseApp@1 -e 'show databases;'  to check whether password being set or not will engage this command and give echo $? if answer is 0 it is already being set else need to be excuted
# VALIDATE $? "setting root password"
# below code will be useful for checking idempotent nature
# cd  /tmp
mysql -hdb.rishvihaan.store -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE

if [ $? -ne 0 ] 
 then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    #VALIDATE $? "Mysql root password setup"
 else 
    echo -e "Mysql root password is already set up...$Y SKIPPING $N"   
 fi
