# to check command properly executing check the status output is 0 or not if zero then shell is executing properly 
func_exit_status() {
  if [ $? -eq 0 ]; then
    echo -e "\e[32m SUCCESS \e[0m"
  else
    echo -e "\e[31m FAILURE \e[0m"
  fi
}
func_check_command() {
 if [$? eq - ]; then 
  echo -e "\e[32m Success \e[0m"
 else 
  echo -e "\e[32m neither suceess or failure \e[0m"
 fi
}
func_apppreq() {
  echo -e "\e[36m>>>>>>>>>>>>  Create ${component} Service  <<<<<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>  Create Application User  <<<<<<<<<<<<\e[0m"
  id roboshop &>>${log}
  if [ $? -ne 0 ]; then
    useradd roboshop &>>${log}
  fi
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>  Cleanup Existing Application Content  <<<<<<<<<<<<\e[0m"
  rm -rf /app &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>  Create Application Directory  <<<<<<<<<<<<\e[0m"
  mkdir /app &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>  Download Application Content  <<<<<<<<<<<<\e[0m"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>>>>>>  Extract Application Content  <<<<<<<<<<<<\e[0m"
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  func_exit_status
}

log=/tmp/roboshop.log
func_app_req() {
 cp ${component}.service /etc/system/systemd/${component}.service &>>${log}
 id roboshop &>> ${log}
 if [$? - ne 0]; then 
   user add roboshop 
else 
   echo -e "\e[32m user already crreated \e[0m "
if
 rm -rf /app &>> {log}
mkdir /app &>> {log}
curl -o /tmp/${component}.zip link/{component}.zip
cd /app
unzip /tmp/${component}.zip &>> {log}
func_exit_status
}
func_system_service_change() {
 echo -e "\e[32m service file changed :::::\e[0m"
 if [$? -ne 0]; then 
   systemctl daemon -reload 
 else 
   systemctl enable ${component}
   systemctl restart${component} 
}

func_schema_setup() {
  if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[36m>>>>>>>>>>>>  INstall Mongo Client  <<<<<<<<<<<<\e[0m"  | tee -a /tmp/roboshop.log
    yum install mongodb-org-shell -y &>>${log}
    func_exit_status

    echo -e "\e[36m>>>>>>>>>>>>  Load User Schema  <<<<<<<<<<<<\e[0m"  | tee -a /tmp/roboshop.log
    mongo --host mongodb.vikramdevops.tech </app/schema/${component}.js &>>${log}
    func_exit_status
  fi

  if [ "${schema_type}" == "mysql" ]; then
    echo -e "\e[36m>>>>>>>>>>>>  Install MySQL Client   <<<<<<<<<<<<\e[0m"
    yum install mysql -y &>>${log}
    func_exit_status

    echo -e "\e[36m>>>>>>>>>>>>  Load Schema   <<<<<<<<<<<<\e[0m"
    mysql -h mysql.vikramdevops.tech -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
    func_exit_status
  fi

}

func_shema_type () {
    if["${schema_type}" == "mongodb"]; then 
       echo -e "\e[32m install mongo client \e[0m"
       mongo --host mongdb.vikramdevops.tech </app/schema/${component}.js &>> {log}
       func_exit_status
    fi
    if["${schema_type}" == "mysql"]; then 
      mysql -h mysql.vikram.devops.tech -uroot -pRoboShop@1 </app/schema/${component}.sql &>> {log}
    fi
}

func_node_js () {
    cp mongo.repo /etc/yum.repos.d/repo
    curl -o rpm | bash 
    func_apppreq
    yum install nodejs -y 
    npm install 
    func_shema_type
    func_systemd
}
fun_java_shipping () {
    cp mongo.repo /etc/yum.repos.d/repo
    curl -o rpm | bash
     func_apppreq
     yum install java 
     mv /target/ship.jar /tmp/ship.jar
     func_schema_setup
     func_systemd

}