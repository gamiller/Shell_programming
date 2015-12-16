#!/bin/bash
#
#Script name: spy.sh
#
# Description: This script checks to see if a list of users are logged onto a machine.  It can track
# multiple users as they log in and out of a given machine.  It also tracks how long they have 
# spent on that machine while the script has run, as well as their longest and shortest session.  It
# then reports this information out in a text file, which compares each user's stats against eachother
# 
# Command Line Options: None
#
# Input: A list of users to track, they can be listed by their full given name (first, middle initial, last)
# or by their full user id.  Partial matches will not be accepted in order to avoid tracking the wrong person.
# If the name has two user ames then the script only takes the first one that is found.
# ex. ./spy.sh "Charles Palmer" "Tony Stark"  
#
# Output: A summary of a user's activity on the computer.  It reads out when the script began and ended 
# running, the usernames that are being searched for, a record of every time a user has logged in and out,
# which user spent the most time logged on today, which user had the shortest and longest session.
#
# Special considerations:  
# *	The given "shortest time" is 99999999999999999999 minutes, an absurdly high number
# 		so as any possible will be less than, but if this program runs long enough to hit it be aware.
# *	For the longest session, shortest session, and most time spent, in case of a tie the recorded user
# 		is the most recently recorded username, so the last parameter given
## *  even if the user was logged in before spy.sh began, the session begins at the current time
#     so therefore the timeIn would be the current time not the user's login time
#
# Pseudocode: The code first checks that at least one parameter has been given, and that this parameter has
# a corresponding username.  The code then declares multiple asociative arrays which store each users info
# about a certain variable.  The script then takes in each parameter and finds the corresponging username which
# is then input over a normal iterable array.  This userArray can then be iterated over to give the usernames 
# which are keys to the other arrays.  While the script has not been killed it goes through each user and checks
# for a change in logging in/out.  For example, if a user is now logged in but had not previously been logged in,
# (signified by a 0) it then updates it's start time and login count as well as its login state.  If a user is 
# now not logged in but had previously been logged out (signified by a 0) then they must update information 
# about the session that occured and updated login state.  To get this information to print as a log file you must 
# kill it with kill -10, and it will be printed to spy.log



# kills the program if there are no given parameters
if [[ $# == 0 ]]
	then exit 1
fi


# the function to run when told to kill the file
killFunction() {
	# initiate variable for who had the shortest session, longest session, and spent the most time logged in
	# variables to store who had each record
	shortestSession=99999999999999999999
	shortSessionUser=" "

	longestSession=0
	longestSessionUser=" "

	mostTime=0
	mostTimeUser=" "

	# this begins a new log file by writing over any previous log
	printf $"
spy.sh Report 
started at $startTime on $startDate
stopped at `date +"%H:%M"` on `date +%D`
arguments: ${userArray[*]} \n
			\n" > spy.log

	# loop through users to give individual reports on their individual sessions
	for i in ${userArray[*]}; do
		currUser=$i

		# if a user is logged in, mark the kill as the end the current session
		# this updates the variables
		exitVariables

		# beginning of individual reports
		printf $"\n $currUser logged on ${loginCount[$currUser]} times for a total period of ${totalTime[$currUser]} minutes. Here is the breakdown:\n" >> spy.log
		
		# read through each user's temporary file log, reporting out each session in a numbered line
		# variable to label counted lines
		lineCount=1
		while read line; do
			printf $"$lineCount) $line \n" >> spy.log
			((lineCount++))
		done <$".tmp.spylog-$currUser-2"
		
		# after finishing reading in the temporary file, delete it
		rm .tmp.spylog-$currUser-2

		# for the next variables, in case of a tie, the most recent user gets assigned the variable
		# see if the current user has the longest session, if so update the variable
		if (( ${longestTime[$currUser]}>=$longestSession ))
			then 
				longestSession=${longestTime[$currUser]}
				longestSessionUser=$currUser
		fi


		# see if the current user has the shortest session, if so update the variable
		if (( ${shortestTime[$currUser]}<=$shortestSession ))
			then 
				shortestSession=${shortestTime[$currUser]}
				shortestSessionUser=$currUser
		fi


		# see if the current user was logged on for the most total time, if so update the variable
		if (( ${totalTime[$currUser]}>=$mostTime ))
			then 
				mostTime=${totalTime[$currUser]}
				mostTimeUser=$currUser
		fi



	done

	# print out the comparisons for most time spent total, and longest and shortest session
	printf $"\n
$mostTimeUser spent the most time logged on today- $mostTime mins in total for all his/her sessions.\n
$shortestSessionUser was on for the shortest sesssion for a period of $shortestSession mins, and therefore the most sneaky.\n
$longestSessionUser was logged on for the longest session of $longestSession mins.\n" >> spy.log



exit 0
}

# when kill -10 is called, the killFunction will run and create a log file
trap 'killFunction' SIGUSR1


# record start time and date of the script running 
startTime=`date +"%H:%M"`
startDate=`date +%D`


# Declaring all of the arrays
# make an array to hold all the user names
userArray=()

# an associative array to hold whether the user is currentl logged in or not
# 1= previously logged in, 0= previously not logged in
declare -A currLogin

# an associative array to hold each user's total time spent logged in
declare -A totalTime

# an associative array to hold each user's longest time logged in
declare -A longestTime

# an associative array to hold each user's shortest time logged in
declare -A shortestTime

# an associative array to hold how many times each user has logged in
declare -A loginCount

# an associative array to hold the date in of the current login for each user
declare -A dateIn

# an associative array to hold the time of individual logins for each user
declare -A timeIn





# for each given parameter find the corresponding user name
for arg in "$@"; do
	# if the parameter has no username then crash the program
	if cat /etc/passwd | grep -q "$arg"
		then 
			# this cuts out only the first user name found
			userName=`cat /etc/passwd | grep "$arg" | cut -d ":" -f1 | head -n 1`
		else
			exit 1
	fi 

	# add the user name to the array of user names
	userArray+=($userName)


	# initiate all arrays to start positions
	currLogin[$userName]=0
	totalTime[$userName]=0
	longestTime[$userName]=0
	shortestTime[$userName]=99999999999999999999
	loginCount[$userName]=0
	# this represents if the user never logs in
	timeIn[$userName]=null
done



# function to update variables when user logs in
enterVariables() {
	# record the date and time when the use logged in
	# note: even if the user was logged in before spy.sh began, the session begins at the current time
	# so therefore the timeIn would be the current time not the user's login time
	timeIn[$currUser]=`date +"%H:%M:%S"`
	dateIn[$currUser]="`date`"

	# add to the login count
	((loginCount[$currUser]+=1))
}



# function to update the exit variables for kill or now logged in
exitVariables() {
	# catches if this function is used at kill but the user never logs in
	# breaks from this loop so that the variables do not falsely update
	if [ ${timeIn[$currUser]} == null ]
		then 
			break
	fi


	# record the time that the user loggedout as current time
	timeOut=`date +"%H:%M:%S"`

	# find time spent logged in
	# script first converts the time to epoch seconds before finding the difference.  
	# As well, 59 seconds are added so that the time is always rounded up
	date1=$(date -d ${timeIn[$currUser]} +"%s")
	date2=$(date -d ${timeOut[$currUser]} +"%s")
	diff=$(($date2-$date1))
	loginTime="$((($diff+59) / 60))"


	# add the current login time to previous to find total time logged in
	((totalTime[$currUser]+=$loginTime))


	# find whether the curent session time is the loggest or shortest time,
	# if so, reassign the respective user variable in an array
	# if tied, set to the newer time
	if [[ $loginTime -gt ${longestTime[$currUser]} ]]
		then longestTime[$currUser]=$loginTime
	fi

	if [[ $loginTime -lt ${shortestTime[$currUser]} ]]
		then shortestTime[$currUser]=$loginTime
	fi

	# write this login/logout event to the user's temporary file
	echo $"Logged on ${dateIn[$currUser]}; logged off `date`" >> .tmp.spylog-$currUser-2

}


# while loop to run continuously until the program is killed
# it checks to see if a user has logged in or out, then sleeps
while [ true ]; do
	# loop through each user
	for i in ${userArray[*]}; do
		currUser=$i
		# if the user is currently logged in on the computer
		if who | grep -q $currUser 
			then 
				# checks if the user just logged into the computer
				if [[ ${currLogin[$currUser]} == 0 ]]
					then 
						# set variables for a new session, signify user logged in
						enterVariables
						currLogin[$currUser]=1
				fi
			else
				# if the user is not logged in, but was previously logged in
				if [[ ${currLogin[$currUser]} == 1 ]]
					then
					# set variables for a log out, signify user logged out
					exitVariables
					currLogin[$currUser]=0
				fi
		fi			
	done
	# sleep for 60 seconds, unless it has been killed
	sleep 60 & wait 
done






