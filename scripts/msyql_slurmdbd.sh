#!/bin/bash
DBPASS=$1
mysql -u root -p"$DBPASS" -e "grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'slurm_pass' with grant option;"
mysql -u root -p"$DBPASS" -e "create database slurm_acct_db;"

