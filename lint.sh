#!/bin/bash
 
find -regextype egrep -regex '.*\.[ch](pp)?$' -exec astyle '{}' --style=allman --indent=spaces=2 --pad-oper --unpad-paren --pad-header --convert-tabs \;
 
find -regextype egrep -regex '.*\.[ch](pp)?.orig$' -exec rm '{}' \;
 
pep8ify -nw .
