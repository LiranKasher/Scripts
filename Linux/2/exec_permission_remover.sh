#!/bin/bash
### This program takes a command line argument for a directory path, and removes execution privileges ###
### from all users, for all files in that directory recursively (excluding the directories themselves). ###
### Important! This script needs to be run as a sudo user, in order to execute permissions change correctly. ###

clear

given_path=""

read -r -p "Please enter the directory path to remove execution permissions from: `echo $'\n> '`" given_path

### Check if the given path exists. ###
while [ ! -d "$given_path" ]
do
      clear
      echo "The path ${given_path} does not exist. Please try again."
      sleep 4
      clear
      read -r -p "Please enter the directory path to remove execution permissions from: `echo $'\n> '`" given_path
done

### Create an array, comprised of the output of the find command; Thus making the found files iterable. ###
files=()
while IFS=  read -r -d $'\0';
do
      files+=("$REPLY")
done < <(find "$given_path" -type f -print0)

### Check if the array is empty, if so, exit the program. ###
if [ -z "${files[*]}" ]
then
      echo "Exiting..."
      exit 2
fi

### Iterate through every item in the array and remove its execution permission. ###
for file in "${files[@]}"
do
      chmod -x "$file"
      if [ $? -ne 0 ]
      then
            echo "Could not change permissions for ${file}."
            errors+=${file}
      fi
done

### Check if there were any errors while trying to remove execution permissions. ###
### If there were errors, display them and exit the program. ###
if [ -n "${errors[*]}" ]
then
      echo "Failed to change permissions for the following file\s:"
      for file in "${errors[@]}"
      do
            echo "${file}"
      done
      exit 1
else
      echo "Execution permissions for files under ${given_path} has been removed successfully."
      exit 0
fi
