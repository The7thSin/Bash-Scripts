#!/bin/bash
#Version 1.0 by George Dimitrov
#License The MIT License (MIT)
#Copyright 2019 George Dimitrov
#NOTE: This script will not work as intended if you have hreflangs in your sitemap.

#USER SPECIFIED
#Gets website
website=$1
#Gets save file name
file_name=$2

#Sitemap file name
file="category-sitemap.xml"

#SCRIPT START

#Downloads file from website
wget "https://"$1"/$file"

#Counts and Lists all links
line_count=$(grep -Eo '(http|https)://[a-zA-Z0-9./?=_-]*' $file | wc -l)
line_value=$(grep -Eo '(http|https)://[a-zA-Z0-9./?=_-]*' $file)

#Removes temporary download sitemap
rm -rf $file
#Prints number of links in sitemap
echo $line_count "URLS"
#Check if output folder exists and make it
if [ ! -d "output" ]; then
	mkdir output
fi
#Terminate if user forgot to add filename to save to
if [ "$2" == "" ]; then
    echo "ERROR: You need to specify a file name to save to!"
    exit 1
else
    #Magic happens (
    for ((i=2; i<=$line_count; i++)); do
        url_checked="$b / $line_count" #progress bar
        echo -en $url_checked \\r #progress bar
	#Split URLS
        url=$(sed -n ${i}p <<< "$line_value")
	#Check header response
        header_check=$(curl --silent --output /dev/null --write-out "%{http_code}" $url)
	#Output to file        
	output="$url $header_check"	
	echo -e $output >> output/$2
        ((b=b+1)) #Add count to progress bar. 
    done
    echo "CHECK COMPLETED: All entries checked and recorded!"
fi

