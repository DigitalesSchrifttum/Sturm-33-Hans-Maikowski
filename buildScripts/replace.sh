#!/bin/sh

i=0

search="<\/body>"

for f in $( ls *.html); do

#  textarea='<div class="textarea'
#
#  if [ $(( i % 2)) == 0 ];
#  then
#    textarea="$textarea even\">"
#  else
#    textarea="$textarea odd\">"
#  fi
  
  replace="<\/div><\/body>"
  command="sed -i 's/$search/$replace/g' $f"
  echo "$search"
  echo "$replace"
  echo "$command"
  eval $command

  ((++i))

done