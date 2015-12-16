#!/bin/bash
#
# Script name: count_files.sh
#
# Description: Counts the number of files of each filetype (i.e. file extensions) in the current
# directory and its subdirectories, and produces a summary report.  THe file also counts files
# with no filetype as group "noext"
#
# Command line options:  None
#
# Input: None, though you should be in the directory of files that you want to count
#
# Output: a list of every file extension with it's corresponing number of file of that type
#
# Special considerations: None 
#
# Pseudocode: The code first finds the files with no file type by finding only files that do not have 
# a period at the end of the file to signify an extension.  It then groups and counts these.  It then
# searches over the firectory again and finds each file type and counts how many of each file type are found


# find all files, not directories, create a string of these files seperated by new lines 
# containing only the file names not the path with the opposite of a search to find file with extensions
noextGroup=`find . -type f -printf "\n%f" | grep -v -e "\..*"`

# count the number of these files
noextNum=`echo $noextGroup | wc -w`

# print out noext as a group with the corresponding number of files
printf $"      $noextNum noext \n"


# find all the other types of files by finding only files, with leading directories removed,
# that end in ".extension" 
# print out the list of each of these, only the extension not the full name,
# while counting each unique group
echo "`find . -type f -printf "\n%f" | grep -o -e "\..*" | sort | uniq -c`"
