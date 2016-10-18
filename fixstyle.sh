#!/bin/bash

if [[ $2 = 'fix']]; then 

#Welcome to regex hell :D
	vim -N -u NONE -E \
-c "argdo %s/(\zs\s\ze//ge |
 %s/\zs\s\ze)//ge |
 %s/;\s*/;/ge |
 %s/;\zs\ze\S.\+$/ /ge |
 %s/\S\zs\ze{/ /ge |
 %s/,\zs\ze\S/ /ge |
 %s/\s\zs\ze,//ge |
 %s/=\zs\ze[^= ]/ /ge |
 %s/\w\zs\ze=/ /ge |
 %s/\w\zs\ze!/ /ge |
 w" \
	 -c wq *.c
 else 
    echo "this program makes a heap of changes to your *.c files"
    echo "Be careful, either understand it or run it on a backup copy"
    echo "otherwise you use at your own risk."
    echo
    echo "Enter the argument 'fix' to run"
    echo
    echo "Note: If you aren't used to vim regex, \zs and \ze represent the"
    echo "start and end of what will be replaced respectively"
fi
