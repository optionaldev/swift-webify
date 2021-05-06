#!/bin/bash

# Read contents of file into a variable
input=$(<input.txt)

# Capture and replace angle brackets with the html code
input="$(sed "s/</\&lt;/" <<< "$input")"
input="$(sed "s/>/\&gt;/" <<< "$input")"

keywords=("class" "false" "func" "if" "in" "init" "import" "let" "nil" "private" "return" "self" "struct" "true" "var")

for keyword in ${keywords[@]} 
do
#   echo $keyword

  # Capture and replace when not at the beginning nor the end 
  input="$(sed "s/\([^[:alnum:]]\)\($keyword\)\([^[:alnum:]]\)/\1<span _cl_ass_=\"keyword\">\2<\/span>\3/" <<< "$input")"
  
  # Capture and replace at the beginning of the line
  input="$(sed -E "s/^($keyword)/<span _cl_ass_=\"keyword\">\1<\/span>/" <<< "$input")"
  
  # Capture and replace at the end of the line
  input="$(sed -E "s/($keyword)$/<span _cl_ass_=\"keyword\">\1<\/span>/" <<< "$input")"
done

# Final capture and replace because we used a placeholder class name due to the
# word "class" being a keyword in both the keyword list and the html syntax
input="$(sed "s/_cl_ass_/class/g" <<< "$input")"

echo "$input"
echo "$input" >output.txt

exit 0
