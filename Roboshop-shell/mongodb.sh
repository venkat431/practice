source common.sh

print_head "Copying mongodb repo file"
cp ${code_dir}/configs/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${log_file}
status_check $?

print_head "Installing MongoDB "
yum install mongodb-org -y &>>${log_file}
status_check $?

print_head "Enabling MongoDB service "
systemctl enable mongod &>>${log_file}
status_check $?

print_head "Starting the MongoDB service "
systemctl restart mongod &>>${log_file}
status_check $?

#update 127.0.0.1 to 0.0.0.0 in conf file
print_head "Updating MongoDB Listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${log_file}
status_check $?

print_head " Restarting MongoDB service "
systemctl restart mongod &>>${log_file}
status_check $?