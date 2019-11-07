#!/bin/bash

#Version 2.0 by George Dimitrov
#License The MIT License (MIT)
#Copyright 2019 George Dimitrov

#SETUP ENVIRONMENT VARIABLES

#MIME email location
mail_path=./mail
#Temporary directory for parsing the MIME email
tmp_dir=./tmp
#Extracted File final location
final_location=./xml
#File NAME, TYPE for extraction
file_type="*.xml"
#wics ftp
ftp_location=./orders

#START OF SCRIPT

#Check if ripMIME is installed.
if ! [ -x "$(command -v ripmime)" ]; then
  echo -e 'Error: ripMIME is not installed.\nBuild it from here https://github.com/inflex/ripMIME'
  exit 1
fi

if [ ! -d "$tmp_dir" ]; then
  mkdir tmp
fi

if [ ! -d "$final_location" ]; then
  mkdir xml
fi

#Get last received email and set it in a Variable
ls -t $mail_path > emails.log

un_proc_mail=()

un_proc_mail+=("$(comm -23 <(sort -n ./emails.log) <(sort -n ./proc_mail.log))")


# shellcheck disable=SC2199
if [[ ${un_proc_mail[@]} ]]; then
  # shellcheck disable=SC2068
  for mail in ${un_proc_mail[@]}; do
    #Rip attachments from MIME email.
    ripmime -i $mail_path/$mail -d $tmp_dir
    cp -r $tmp_dir/$file_type $final_location
    python3 xmlparse.py
    mv order*.xml $ftp_location
    rm -rf "${tmp_dir:?}/"*
  done
fi
rm -rf "${final_location:?}/"*
#for i3 in ${un_proc_mail[@]}; do
#Set last processed email in the file if not create or die
if test -f proc_mail.log; then
	for s in "${un_proc_mail[@]}"; do
	  if [[ $s ]]; then
		  echo "$s" >> proc_mail.log
	  fi
	done
else
	#Create log file	
	touch proc_mail.log
	#Add last processed email to the log file
	for s in "${un_proc_mail[@]}"; do
	  if [[ $s ]]; then
		  echo "$s" >> proc_mail.log
	  fi
	done
fi


