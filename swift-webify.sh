#!/bin/bash

# Read the content, line by line and adds that line as an element of the array 'result'
# The content is read from the folder marked
# '$1' gets replace by the first argument passed, forming the path of the file to read
function readMarked() {
  while IFS= read -r line; do
    result+=($line);
  done < "marked/$1.txt"

  echo ${result[*]}
}

function generateOutput() {
  # Read contents of file into variable called 'input'
  input="$(<$1.txt)"
  
  # Capture and replace angle brackets with the equivalent html code
  # In Swift we have generics which have the format <Type> which conflicts with html tags that have the same format
  input="$(sed "s/</\&lt;/" <<< "$input")"
  input="$(sed "s/>/\&gt;/" <<< "$input")"
  
  ####################
  # Keyword handling #
  ####################
  
#   echo "Colorizing keywords.."
   
  keywords=$(readMarked keywords)
  
  # How to print the entire array
  # echo ${keywords[*]}
  
  for keyword in ${keywords[@]} 
  do
    # Capture and replace when not at the beginning nor the end 
    input="$(sed "s/\([(|[:space:]]\)\($keyword\)\([[:space:]|)|(|,]\)/\1<a>\2<\/a>\3/" <<< "$input")"
    
    # Capture and replace at the beginning of the line
    input="$(sed -E "s/^($keyword)/<a>\1<\/a>/" <<< "$input")"
    
    # Capture and replace at the end of the line
    input="$(sed -E "s/($keyword)$/<a>\1<\/a>/" <<< "$input")"
  done
  
  ###########################
  # Built-in types handling #
  ###########################
  
#   echo "Colorizing built-in types.."
  
  builtinTypes=$(readMarked builtinTypes)
  
  for builtinType in ${builtinTypes[@]} 
  do
    input="$(sed "s/\([^[:alnum:]]\)\($builtinType\)\([^[:alnum:]]\)/\1<b>\2<\/b>\3/" <<< "$input")"
    
    input="$(sed -E "s/^($builtinType)/<b>\1<\/b>/" <<< "$input")"
    
    input="$(sed -E "s/($builtinType)$/<b>\1<\/b>/" <<< "$input")"
  done
  
  ######################
  # Operators handling #
  ######################
  
#   echo "Colorizing operators.."
  
  operators=$(readMarked operators)
  
  for operator in ${operators[@]} 
  do
    input="$(sed -E "s/($operator)/<u>\1<\/u>/g" <<< "$input")"
  done
  
  # We want to color _ but only those that represent bindings
  input="$(sed "s/\([^[:alnum:]]\)_\([[:alnum:]]\)/\1<u>_<\/u>\2/g" <<< "$input")"
  
  # We don't want to color the != as well
  input="$(sed "s/\([[:alnum:]|[:space:]]\)!\([[:alnum:]|[:space:]]\)/\1<p>!<\/p>\2/g" <<< "$input")"
  
  
  ############################
  # Built-in values handling #
  ############################
  
#   echo "Colorizing other built-in methods.."
  
  builtinValues=$(readMarked builtinValues)
  
  for builtinValue in ${builtinValues[@]} 
  do
    input="$(sed "s/\.\($builtinValue\)\([^[:alnum:]]\)/\.<i>\1<\/i>\2/g" <<< "$input")"
    
    input="$(sed -E "s/\.($builtinValue)$/\.<i>\1<\/i>/" <<< "$input")"
  done
  
  ######################################
  # Built-in global functions handling #
  ######################################
  
#   echo "Colorizing built-in global functions.."
  
  builtinMethods=("print")
  
  for builtinMethod in ${builtinMethods[@]} 
  do
    input="$(sed "s/\([[:space:]]\)\($builtinMethod\)(/\1<i>\2<\/i>(/g" <<< "$input")"
  done
  
  #################
  # func handling #
  #################
  
#   echo "Colorizing functions names.."
  
  methods=$(readMarked functions)
  
  for method in ${methods[@]} 
  do
    input="$(sed "s/\([[:space:]]\)\($method\)(/\1<s>\2<\/s>(/g" <<< "$input")"
  done
  
  ######################
  # constants handling #
  ######################
  
#   echo "Colorizing string & digit constants.."
  
  # Handle when "" is somewhere in the middle of the line of code, like before a && or ||
  input="$(sed "s/\([^[:alnum:]]\)\"\"\([^[:alnum:]]\)/\1<q>\"\"<\/q>\2/g" <<< "$input")"
  
  # Handle when there is text between ""
  input="$(sed "s/\"\([^\"].*\)\"/<q>\"\1\"<\/q>/" <<< "$input")"
  
  # Handle when "" is the final thing on the line of code
  input="$(sed -E "s/\"\"$/<q>\"\"<\/q>/" <<< "$input")"
  
  # write to output file
  echo "$input" 
}

# generateOutput "test/input" >output.txt
# lol = generateOutput "test/input"
generatedOutput=$(generateOutput "test/input");
expectedOutput=$(<"test/output.txt")

# input=$(<input.txt)

if [ expectedOutput != generatedOutput ]; then
  echo "Test failed"
  echo "$generatedOutput"
else 
  echo "$(generateOutput "input")" >output.txt
fi

exit 0
