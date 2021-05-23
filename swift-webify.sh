#!/bin/bash

# Read contents of file into variable called 'input'
input=$(<input.txt)

# Capture and replace angle brackets with the html code
input="$(sed "s/</\&lt;/" <<< "$input")"
input="$(sed "s/>/\&gt;/" <<< "$input")"


#   input="$(sed -E "s/([[:alnum:][:space:]])\=([[:alnum:][:space:]])/\1<span class=\"operator\">\=<\/span>\2/g" <<< "$input")"

####################
# Keyword handling #
####################

echo "Colorizing keywords.."

keywords=("class" "didSet" "else" "false" "final" "func" "if" "in" "init" "import" "let" "nil" "private" "return" "self" "some" "static" "struct" "true" "var")

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

echo "Colorizing built-in types.."

builtinTypes=("Binding" "Bool" "Color" "Coordinator" "Context" "NotificationCenter" "NSObject" "ObservableObject" "ObservedObject" "NSRange" "NSString" "Published" "String" "State" "UITextField" "UITextFieldDelegate" "UIViewRepresentable" "UIViewRepresentableContext" "View" "VStack")

for builtinType in ${builtinTypes[@]} 
do
  input="$(sed "s/\([^[:alnum:]]\)\($builtinType\)\([^[:alnum:]]\)/\1<b>\2<\/b>\3/" <<< "$input")"
  
  input="$(sed -E "s/^($builtinType)/<b>\1<\/b>/" <<< "$input")"
  
  input="$(sed -E "s/($builtinType)$/<b>\1<\/b>/" <<< "$input")"
done

######################
# Operators handling #
######################

echo "Colorizing operators.."

operators=("&&" "\|\|" "\\$" "==" "\?\?")

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

echo "Colorizing other built-in methods.."

builtinValues=("addObserver" "autocapitalizationType" "background" "blue" "becomeFirstResponder" "center" "default" "coordinator" "delegate" "font" "isFirstResponder" "main" "none" "onChange" "red" "removeObserver" "replacingCharacters" "resignFirstResponder" "systemFont" "text" "textAlignment" "textColor" "textDidChangeNotification" "zero")

for builtinValue in ${builtinValues[@]} 
do
  input="$(sed "s/\.\($builtinValue\)\([^[:alnum:]]\)/\.<i>\1<\/i>\2/g" <<< "$input")"
  
  input="$(sed -E "s/\.($builtinValue)$/\.<i>\1<\/i>/" <<< "$input")"
done

######################################
# Built-in global functions handling #
######################################

echo "Colorizing built-in global functions.."

builtinMethods=("print")

for builtinMethod in ${builtinMethods[@]} 
do
  input="$(sed "s/\([[:space:]]\)\($builtinMethod\)(/\1<i>\2<\/i>(/g" <<< "$input")"
done

#################
# func handling #
#################

methods=("backwardUpdate" "dismantleUIView" "forwardUpdate" "makeCoordinator" "makeUIView" "textField" "updateUIView")

for method in ${methods[@]} 
do
  input="$(sed "s/\([[:space:]]\)\($method\)(/\1<s>\2<\/s>(/g" <<< "$input")"
done

######################
# constants handling #
######################

# constants=("\"\"")

# Handle when "" is somewhere in the middle of the line of code, like before a && or ||
input="$(sed "s/\([^[:alnum:]]\)\"\"\([^[:alnum:]]\)/\1<q>\"\"<\/q>\2/g" <<< "$input")"

# Handle when there is text between ""
input="$(sed "s/\"\([^\"].*\)\"/<q>\"\1\"<\/q>/" <<< "$input")"

# Handle when "" is the final thing on the line of code
input="$(sed -E "s/\"\"$/<q>\"\"<\/q>/" <<< "$input")"

# write to output file
echo "$input" >output.txt

exit 0
