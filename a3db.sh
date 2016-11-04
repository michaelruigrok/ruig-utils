if [[ $# -eq 0 ]]; then echo "You need a test argument bro"; exit; fi

testprogram="testa3.sh explain $1"

#get the executable and arguments for that specific test
test=`$testprogram | awk 'NR==8'`
eval $test #run it

#take the arguments and construct a gdb run argument out of them (in gdb.run)
#type 'so[urce] gdb.run' to use it
echo -n 'r ' > ./gdb.run
echo "$test" | cut -d\  -f 2- | rev | cut -d\  -f 5- | rev > ./gdb.run

diffthis=`$testprogram | grep ".$stream tests/" | cut -d\  -f 2-`
for stream in 'out' 'err'; 
do
	if eval "diff -b" $diffthis; then
		echo "std$stream:"
		eval "diff -y" $diffthis
	   	echo
	else echo "std$stream matches!"
	fi
done
