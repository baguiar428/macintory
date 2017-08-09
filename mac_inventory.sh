#!/bin/bash

# This is a script for collecting Mac Inventory.
# The Script prompts a user for their name then collects key system information. (i.e: Serial #, Model configuration and user accounts)
# The collected information is saved to a file on the desktop. (labeled in FLast_name format)
# To run the script grant file u+x (755) permissions. Changing .sh extension to .command will allow user to run script by clicking on file. No terminal required.

#Setup - Collection of users name
echo "Hello, let's start by getting your first name:"
read first_name
initial="$(echo $first_name | head -c 1)"
echo "Your last name: "
read last_name
filename=$(echo $initial$last_name | sed 's/ /_/g')
clear

#Run-Time - Collection of system Information
echo -e "Thank you, $first_name $last_name.\n"
echo -e "Sending your info to the mothership...\n"
echo -e "$first_name $last_name\n" >> ~/Desktop/$filename
# This uses the systems model identifier to query against Apples Support site for a more readable model format. (i.e: Model MacbookPro13,3 -> Macbook Pro (15-Inch, 2016)
# If this line doesn't work..The Apple support site may be down or they changed the sites layout.
curl -s http://support-sp.apple.com/sp/product?cc=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' | cut -c 9-` | sed 's|.*<configCode>\(.*\)</configCode>.*|\1|' >> ~/Desktop/$filename
echo -e "\nUsers on System:" >> ~/Desktop/$filename
dscl . list /Users | egrep -v "^_.*|daemon|nobody|root|Guest" >> ~/Desktop/$filename
system_profiler SPHardwareDataType | grep -v Hardware: >> ~/Desktop/$filename
system_profiler SPAirPortDataType | grep "MAC" >> ~/Desktop/$filename
# Uncomment the line below if you want to send the output file somewhere else. (i.e: AWS Bucket)
#curl -k --request PUT --upload-file ~/Desktop/$filename "https://AWS_Bucket_Location_Goes_Here" *Be mindful of bucket configuration/security.
echo "Success!!!"
exit 0