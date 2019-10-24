#!/bin/bash

#Version 1.0 by George Dimitrov
#License The MIT License (MIT)
#Copyright 2019 George Dimitrov

#SETUP ENVIRONMENT VARIABLES

#MIME email location
mail_path=./mail
#Temporary directory for parsing the MIME email
tmp_dir=./tmp
#Extracted File final location (ftp accesible dir or local dir)
final_location=./
#File NAME, TYPE for extraction
file_type=*.xml

#START OF SCRIPT

#Check if ripMIME is installed.
if ! [ -x "$(command -v ripmime)" ]; then
  echo -e 'Error: ripMIME is not installed.\nBuild it from here https://github.com/inflex/ripMIME'
  exit 1
fi

#Last email log file
log=lastmail.log
#Set last received email in a Variable
email=$(ls -t $mail_path | head -n1)

#Set last processed email to file
if test -f lastmail.log; then
	#Read last processed email name from a File
	last_email=$(cat $log)
	#Check if the email has been processed before
	if [[ "$last_email" == "$email" ]]; then
		exit 1
	fi
else
	#Create log file	
	touch lastmail.log
	#Add last processed email to the log file
	echo $email > lastmail.log
fi

#Rip attachments from MIME email.
ripmime -i $mail_path/$email -d $tmp_dir
#Copy the email to specific user
cp $tmp_dir/$file_type $final_location
#Clean temporary folder
rm -rf $tmp_dir/*
