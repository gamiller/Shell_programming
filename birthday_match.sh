#!/bin/bash
#
#Script name: birthday_match.sh
#
# Description: Takes two birthdays (or general dates) and determines whether the two 
# dates occured on the same day of the week
# 
# Command Line Options: None
#
# Input: Two valid dates in the form XX/XX/XXXX.  Code will exit if not in correct format
#
# Output: prints out whether the dates occured on the same day of the week
#
# Pseudocode: The code first check to make sure that the parameters are in the right format and are
# valid dates.  It then uses the date command to find which day of week each date occured.  It then compares
# the two days to see if they are the same, and prints out whether or not they are


# first check that there are 2 arguments given
if [[ $# != 2 ]]
	then exit 1
fi


# loop through each date to ensure that it is a real date in the correct format
for arg
do 
	# checks that the date is in the format XX/XX/XXXX, if not, exit
	if [[ $arg != `echo $arg | grep -E "^[0-9]{2}/[0-9]{2}/[0-9]{4}$"` ]]
		then 
			exit 1
	fi

	# checks to ensure that it is a real date, if not, exit
	date -d $arg > /dev/null
	if [[ $? != 0 ]];
		then
			exit 1
	fi
done



# find day 1 day of the week
date1=`date -d $1 +%A`
printf "The first person was born on: $date1 \n"

# find day 2 day of the week
date2=`date -d $2 +%A`
printf "The second person was born on: $date2 \n"


# compares to see if the dates are on the same day
if [[ $date1 == $date2 ]]
	then 
		printf "Jackpot! You were both born on the same day of the week! \n"
	
	else 
		printf "Therefore, you are not born on the same day of the week. \n"
fi

# if the code doesn't break, exit 0
exit 0