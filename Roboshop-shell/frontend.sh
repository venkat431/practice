source common.sh

print_head "Installing Nginx"
yum install nginx -y &>>${log_file}
status_check $?

print_head "Removing old files"
rm -rf /usr/share/nginx/html/*  &>>${log_file}
status_check $?

print_head "Download Frontend file"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${log_file}
status_check $?

cd /usr/share/nginx/html

print_head "Extracting the downloaded files "
unzip /tmp/frontend.zip &>>${log_file}
status_check $?

print_head "Copying config file"
cp ${code_dir}/configs/nginx-roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${log_file}
status_check $?

print_head "Enabling Nginx "
systemctl enable nginx &>>${log_file}
status_check $?

print_head "Starting Nginx  "
systemctl restart nginx &>>${log_file}
status_check $?