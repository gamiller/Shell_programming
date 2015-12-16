#!/bin/bash
#
# Script name: url_search.sh
#
# Description: processes two parameters: a text file (containing a list of URLs) and 
# one or more words as arguments, and searches for occurences of the word(s) in the 
# webpages found at the listed URLs. 
#
# Command line options:  None
#
# Input: The first parameter must be a text file with lists URLs, each on its own lin
# Then there can be one or more words as the 2nd to n parameters that will be searched for
#
# Output: prints out each word being search, and how many times it was found in the html
# code for each specific webpage
#
# Special considerations:  each word is searched for in the html code of the URL
#
# Pseudocode: The code goes through the words given that will be searched for individually, 
# and for each word it goes through the given text file and loops over each URL.  It then 
# creates a temporary file of that URL's html code then searches through the html code
# for the given word.  It then removes the temporary file and loops through each URL then
# each word.


# fileNum is a variable to number the html files created, starting with 1
fileNum=1

# loop through words to search for in the html files
for arg; do
	# this excludes the first parameter, the text file of URLs
	if [[ $arg != $1 ]]
		# print the word being searched for
		then printf "\n$arg \n"
			# enters the text file of URLs
			for url in `cat $1`; do
			# print out the html code for a given url to a numbered temporary file
			# use -s to prevent the printing of the progress bar while curl runs
			htmlFile=$"$fileNum".html""  

			curl -s -o $htmlFile $url

			# prints the url of the html currently being searched
			printf $url

			# prints the number of times the word is found in the html code
			printf "  `cat $htmlFile | grep -i -r -o -e $arg | wc -w` \n"
			
			# remove each temporary html file after it has been searched for each word
			rm $htmlFile 

			#increment the number of the file for a new file name
			let "fileNum++"

			done
	fi
done


