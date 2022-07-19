#!/bin/bash
### This program takes a command line argument for a directory path, ###
### and returns the system mount point path for the given directory. ###


clear

given_path=""

read -r -p "Please enter the required directory path to be pointed at: `echo $'\n> '`" given_path

### Check if the given path exists. ###
while [ ! -d "$given_path" ]
do
      clear
      echo "The path ${given_path} does not exist. Please try again."
      sleep 4
      clear
      read -r -p "Please enter the required directory path to be pointed at: `echo $'\n> '`" given_path
done

mount_point=$(findmnt "$given_path")

### Check if the variable value is empty. ###
if [ -z "$mount_point" ]
then
      echo "No mount point found for ${given_path}"
      exit 1
else
      echo "Found mount point for ${given_path}:"
      echo "${mount_point}"
      exit 0
fi
