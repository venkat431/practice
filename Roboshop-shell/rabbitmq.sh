source common.sh

roboshop_app_password=$1
if [ -z "${roboshop_app_password}" ]; then
  echo -e "\e[31mRoboshop App password argument is missing\e[0m"
  exit 1
fi

print_head " Downloading Erlang files "
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${log_file}
status_check $?

print_head " Downloading Rabbitmq server files "
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${log_file}
status_check $?

print_head " Installing Rabbitmq server & Erlang "
yum install rabbitmq-server erlang -y &>>${log_file}
status_check $?

print_head " Enabling RabbitMQ service "
systemctl enable rabbitmq-server &>>${log_file}
status_check $?

print_head " Starting RabbitMQ service "
systemctl restart rabbitmq-server &>>${log_file}
status_check $?

print_head " Create Application user"
rabbitmqctl list_users | grep roboshop &>>${log_file}
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop ${roboshop_app_password} &>>${log_file}
fi
status_check $?

#rabbitmqctl set_user_tags roboshop administrator &>>${log_file}
#status_check $?

print_head " Configure Permissions for App user "
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${log_file}
status_check $?
