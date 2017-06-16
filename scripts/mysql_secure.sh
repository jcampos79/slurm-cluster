#!/bin/bash

yum -y install expect

MYSQL_PASS='qaz123wsx'
ACTUAL_PASS=''
SECURE_MYSQL=$(expect -c "
  set timeout 10
  spawn mysql_secure_installation
  expect \"Enter current password for root (enter for none):\"
  send -- \"${ACTUAL_PASS}\r\"
  expect \"Set root password?\"
  send -- \"y\r\"
  expect \"New password:\"
  send -- \"${MYSQL_PASS}\r\"
  expect \"Re-enter new password:\"
  send -- \"${MYSQL_PASS}\r\"
  expect \"Remove anonymous users?\"
  send -- \"y\r\"
  expect \"Disallow root login remotely?\"
  send -- \"y\r\"
  expect \"Remove test database and access to it?\"
  send -- \"y\r\"
  expect \"Reload privilege tables now?\"
  send -- \"y\r\"
  expect eof
")

echo "${SECURE_MYSQL}"

yum -y remove expect
~
~

