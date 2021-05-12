#!/bin/bash

# Read contents of file into variable called 'input'
input=$(<input.txt)

# Capture and replace angle brackets with the html code
input="$(sed "s/</\&lt;/" <<< "$input")"
input="$(sed "s/>/\&gt;/" <<< "$input")"

####################
# Keyword handling #
####################

echo "Colorizing keywords.."

keywords=("class" "false" "func" "if" "in" "init" "import" "let" "nil" "private" "return" "self" "some" "struct" "true" "var")

for keyword in ${keywords[@]} 
do
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

###########################
# Built-in types handling #
###########################

echo "Colorizing built-in types.."

builtinTypes=("Binding" "Bool" "Color" "Context"  "NotificationCenter" "NSObject" "String" "State" "UITextField" "UITextFieldDelegate" "UIViewRepresentable" "UIViewRepresentableContext" "View" "VStack")

for builtinType in ${builtinTypes[@]} 
do
  input="$(sed "s/\([^[:alnum:]]\)\($builtinType\)\([^[:alnum:]]\)/\1<span class=\"builtinType\">\2<\/span>\3/" <<< "$input")"
  
  input="$(sed -E "s/^($builtinType)/<span class=\"builtinType\">\1<\/span>/" <<< "$input")"
  
  input="$(sed -E "s/($builtinType)$/<span class=\"builtinType\">\1<\/span>/" <<< "$input")"
done

######################
# Operators handling #
######################

echo "Colorizing operators.."

operators=("&&" "||" "$")

for operator in ${operators[@]} 
do
  input="$(sed "s/\([[:alnum:]|[:space:]]\)\($operator\)\([[:alnum:]|[:space:]]\)/\1<span class=\"operator\">\2<\/span>\3/g" <<< "$input")"
done

input="$(sed "s/\([[:alnum:]|[:space:]]\)!\([[:alnum:]|[:space:]]\)/\1<span class=\"exclamation\">!<\/span>\2/g" <<< "$input")"

############################
# Built-in values handling #
############################

echo "Colorizing other methods.."

builtinValues=("addObserver" "autocapitalizationType" "background" "becomeFirstResponder" "center" "default" "coordinator" "delegate" "main" "none" "onChange" "red" "text" "textAlignment" "textDidChangeNotification" "zero")

for builtinValue in ${builtinValues[@]} 
do
  input="$(sed "s/\.\($builtinValue\)\([^[:alnum:]]\)/\.<span class=\"otherBuiltin\">\1<\/span>\2/g" <<< "$input")"
  
  input="$(sed -E "s/\.($builtinValue)$/\.<span class=\"otherBuiltin\">\1<\/span>/" <<< "$input")"
done

######################################
# Built-in global functions handling #
######################################

echo "Colorizing built-in global functions.."

builtinMethods=("print")

for builtinMethod in ${builtinMethods[@]} 
do
  input="$(sed "s/\.\($builtinMethod\)\([^[:alnum:]]\)/\.<span class=\"otherBuiltin\">\1<\/span>\2/g" <<< "$input")"
  
  input="$(sed -E "s/\.($builtinMethod)$/\.<span class=\"otherBuiltin\">\1<\/span>/" <<< "$input")"
done

#################
# func handling #
#################

methods=("backwardUpdate" "forwardUpdate" "makeCoordinator" "makeUIView" "updateUIView")

for method in ${methods[@]} 
do
  input="$(sed "s/\($method\)/<span class=\"method\">\1<\/span>/g" <<< "$input")"
done

######################
# constants handling #
######################

constants=("\"\"")

for constant in ${constants[@]} 
do
  input="$(sed "s/\([[:alnum:]|[:space:]]\)\($constant\)\([[:alnum:]|[:space:]]\)/\1<span class=\"constant\">\2<\/span>\3/g" <<< "$input")"
  
  input="$(sed -E "s/($constant)$/<span class=\"constant\">\1<\/span>/" <<< "$input")"
done

# write to output file
echo "$input" >output.txt

exit 0
