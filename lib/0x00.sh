#!/usr/bin/env bash
# Library for null

declare TRUE=0
declare FALSE=1

#---------------------------------------------------------------

# Help function
function null_usage () {
	printf """Usage: 
	-l 	list of all scripts installed 
	-s 	search a script using a keyword
	-i 	informations about a script
	-u 	check for updates
\n"""
	return $TRUE
	exit 1
}

#---------------------------------------------------------------

# List all the scripted that are currently installed
function null_list() {
	# Iterate all the file in the bin folder
	for f in $local_path/bin/*; do
		app=$(basename $f)
		info=$(sed -n 2p $f)
		# Output
		printf "${Green}%12s ${Yellow}%s\n" "$app" "$info"
	done
	echo
	return $TRUE
}

#---------------------------------------------------------------

# Search through the scripts description
function null_search() {
	# Checks for keyword
	# Search all the entries and store it in a variable
	local_result=$(null -l | grep -i $OPTARG)
	# If result is not empty print it
	if [ -n "$local_result" ]; then
		printf "$local_result\n\n"
		return $TRUE
		exit 0
	else
		# Error message
		printf "\n${Red}\tNo results found!\n\n"
		return $FALSE
		exit 1
	fi				
}

#---------------------------------------------------------------

# Print script's information
function null_info() {
	# Iterate apps
	# DEPRECATE; WILL USE FIND INSTEAD?
	for f in $local_path/bin/*; do
		# If the argument match the name of the app
		# Pars information
		if [[ "$(basename $f)" == "$OPTARG" ]]; then	    	
			# HEAD
			printf "${NC}Name: ${Green}$(basename $f)$NC\n"
			# Version
			printf "${NC}Version:${Green}$(cat $f | sed -n '3p' | cut -d '#' -f 2)\n"
			# Description
			printf "${NC}Description:${Green}$(cat $f | sed -n '4p' | cut -d '#' -f 2)\n"
			# if TODO exist print the list
			if [[ $(cat $f | sed -n '/# TODO/,/# EOT/p') ]];then
		 		printf "${NC}TODO:${Green}\n$(cat $f | sed -n '/# TODO/,/# EOT/p' | sed '1d;$d' | cut -f 2 -d '#')\n"
			fi
			# App found, exit 0
			return $TRUE
			exit 0
	 	fi
	done
	# Loop end, return error message
	printf "${Red}\tNothing found!\n\n"
	# RETURN?
}

#---------------------------------------------------------------

# Check update
function null_update() {
	printf "${NC}Checking for updates...\n"
	last_version=$(curl -s $server | grep current_version= | head -n 1 | cut -f 2 -d '=')
	if [ $current_version == $last_version ]; then
		printf "\n${Green}Up-to-date.\n\n"
		return $TRUE
		exit 0
	else
		printf "\n${Red}Current version: ${NC}$current_version"
		printf "\n${Green}  Newer version: ${NC}$last_version\n\n"
		return $FALSE
		exit 1
	fi
}
# EOF