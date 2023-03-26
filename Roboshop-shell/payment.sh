source common.sh

component=payment
roboshop_app_password=$1
if [ -z "${roboshop_app_password}" ] ;then
  echo -e "\e[31mRoboshop app password is missing\e[0m"
  exit 1
fi

python