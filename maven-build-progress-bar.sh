#!/bin/bash

#
# executes mvn clean for all sub directories containing a pom.xml
#

#find .. -name "pom.xml" -exec sh -c "echo $(dirname '{}') && pwd && mvn clean -f '{}'" \;

SLEEP_DURATION=${SLEEP_DURATION:=1}  # default to 1 second, use to speed up tests

progress-bar() {
  local duration
  local columns
  local space_available
  local fit_to_screen  
  local space_reserved

  space_reserved=6   # reserved width for the percentage value
  duration=${1}
  elapsed=${2}
  artifactory=${3}
  columns=$(tput cols)
  space_available=$(( columns-space_reserved ))

  if (( duration < space_available )); then 
  	fit_to_screen=1; 
  else 
    fit_to_screen=$(( duration / space_available )); 
    fit_to_screen=$((fit_to_screen+1)); 
  fi

  already_done() { for ((done=0; done<(elapsed / fit_to_screen) ; done=done+1 )); do printf "▇"; done }
  remaining() { for (( remain=(elapsed/fit_to_screen) ; remain<(duration/fit_to_screen) ; remain=remain+1 )); do printf " "; done }
  percentage() { printf "| %s%% %s" $(( ((elapsed)*100)/(duration)*100/100 )) $artifactory;}
  clean_line() { printf "\r"; }

  #for (( elapsed=1; elapsed<=duration; elapsed=elapsed+1 )); do
      already_done; remaining; percentage
  #    sleep "$SLEEP_DURATION"
      clean_line
  #done
  clean_line
}
export -f progress-bar

#find .. -name "pom.xml" -print0 | xargs -0 -L 1 -P10 sh -c 'echo $0 &&  mvn -f "$0" clean -l _logs.txt';

i=0
file_array=()

mapfile -d $'\0' file_array < <(find .. -name "pom.xml" -print0)

len=${#file_array[*]}
echo "found : ${len}"

while [ $i -lt $len ]
do	
	dir_name=$(dirname ${file_array[$i]})
	logfile=${dir_name##*/}
#	echo $logfile
#	echo ${file_array[$i]}
	echo ${file_array[$i]} | xargs -0 -L 1 -P10 sh -c 'mvn -f $0 clean' > logs/$logfile.log;
	progress-bar $len $i $logfile
	let i++
done
