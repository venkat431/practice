code_dir=$(pwd)

log_file=/tmp/roboshop_log.log
rm -f ${log_file}

print_head() {
  echo -e "\e[36m $1 \e[0m"
}

status_check() {
  if [ $1 -eq 0 ]; then
    echo SUCCESS
    else
      echo FAILURE
      echo "Read the log file at ${log_file} for errors"
      exit 1
  fi
}
app_prereq_setup() {
  print_head "Adding application user "
  id roboshop &>>${log_file}
  if [ $? -ne 0 ]; then
    useradd roboshop &>> ${log_file}
  fi
  status_check $?

  print_head "Creating Application directory "
  if [ ! -d /app ]; then
    mkdir /app &>>${log_file}
  fi
  status_check $?

  print_head "Removing Old files "
  rm -rf /app/* &>>${log_file}
  status_check $?

  print_head "Downloading ${component} files "
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log_file}
  status_check $?

  cd /app &>>${log_file}

  print_head "Extracting Files "
  unzip /tmp/${component}.zip &>>${log_file}
  status_check $?

}
systemd_setup() {
  print_head "Copying service file"
  cp ${code_dir}/configs/${component}.service /etc/systemd/system/${component}.service &>>${log_file}
  status_check $?
  sed -i -e "s/ROBOSHOP_USER_PASSWORD/${roboshop_app_password}/" /etc/systemd/system/${component}.service &>>${log_file}

  print_head "Reloading the Service"
  systemctl daemon-reload &>>${log_file}
  status_check $?
  
  print_head "Enabling ${component} Service"
  systemctl enable ${component} &>>${log_file}
  status_check $?
  
  print_head "Starting ${component} Service  "
  systemctl restart ${component} &>>${log_file}
  status_check $?
}

schema_setup() {
  if [ "${schema_type}" == "mongo" ]; then
    print_head "Copying MONGODB repo file  "
    cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
    status_check $?

    print_head "Installing MongoDB client "
    yum install mongodb-org-shell -y &>>${log_file}
    status_check $?

    print_head "Load MongoDB database"
    mongo --host mongodb-dev.devops-practice.tech </app/schema/${component}.js &>>${log_file}
    status_check $?
  elif [ "${schema_type}" == "mysql" ]; then
    print_head "Installing mysql "
    yum install mysql -y &>>${log_file}
    status_check $?

    print_head "Connecting mysql database"
    mysql -h mysql-dev.devops-practice.tech -uroot -p${mysql_root_password} < /app/schema/${component}.sql &>>${log_file}
    status_check $?
  fi
}

nodejs() {
  print_head "Downloading Nodejs repo "
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log_file}
  status_check $?
  
  print_head "Installing Nodejs "
  yum install nodejs -y &>>${log_file}
  status_check $?
  
  app_prereq_setup
  
  cd /app &>>${log_file}
  print_head "Installing npm packages "
  npm install &>>${log_file}
  status_check $?

  schema_setup

  systemd_setup
}

java() {
  print_head "Installing Maven"
  yum install maven -y &>>${log_file}
  status_check $?

  #Setting Application prerequisites by calling function
  app_prereq_setup

  cd /app &>>${log_file}

  print_head "Cleaning Maven package"
  mvn clean package &>>${log_file}
  status_check $?

  print_head "Moving Jar file to application folder"
  mv target/${component}-1.0.jar ${component}.jar &>>${log_file}
  status_check $?

  #Schema setup function is calling
  schema_setup
  #systemd setup function is calling
  systemd_setup
}


python() {
  print_head "Installing Python"
  yum install python36 gcc python3-devel -y &>>${log_file}
  status_check $?

  #Setting Application prerequisites by calling function
  app_prereq_setup

  cd /app &>>${log_file}

  print_head "Download python dependencies"
  pip3.6 install -r requirements.txt &>>${log_file}
  status_check $?

  #systemd setup function is calling
  systemd_setup
}

golang() {

  print_head "Installing golang "
  yum install golang -y &>>{log_file}
  status_check $?

  app_prereq_setup

  cd /app

  print_head "Initiate dispatch "
  go mod init dispatch &>>{log_file}
  status_check $?

  print_head "Get "
  go get &>>{log_file}
  status_check $?

  print_head "Build "
  go build &>>{log_file}
  status_check $?

  systemd_setup

}