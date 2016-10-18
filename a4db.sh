if [[ $# -eq 0 ]]; then
    echo "You need a test argument bro";
    echo "Usage: a4db TESTNAME DIFFCOLUMNS";
    echo "(a4db.sh --help for help)";
    exit;
fi

if [[ $1 = "--help" ]]; then
    echo "Usage: a4db TESTNAME DIFFCOLUMNS"
    echo
    echo "if DIFFCOLUMNS is 'single', diff will print in 1 column"
    echo "if DIFFCOLUMNS is 'vim', vimdiff will run instead"
    echo "otherwise it will diff in side-by-side mode"
    echo
    echo "This program will:"
    echo "1) Run the associated test"
    echo "2) print both the stdout and stderr diffs"
    echo "3) create a GDB source file (gdb.run) containing a gdb"
    echo "run command with appropriate arguments."
    echo "To use gdb.run, boot up GDB with the appropriate executable"
    echo "argument, and then enter the command 'source gdb.run'"
    echo "in place of the regulary 'run' command"
    exit
fi

testprogram="testa4.sh explain $1"

#get the executable and arguments for that specific test
test=`$testprogram | awk 'NR==8'`
echo $test
eval $test #run it

#take the arguments and construct a gdb run argument out of them (in gdb.run)
#type 'so[urce] gdb.run' to use it
echo -n 'r ' > ./gdb.run
echo "$test" | cut -d\  -f 2- | rev | cut -d\  -f 5- | rev >> ./gdb.run

diffarg='diff -y '
if [[ $2 = 'single' ]]; then
	diffarg='diff '
	echo "second argument is 'single'; gonna output diff in one column"
elif [[ $2 = 'vim' ]]; then
	diffarg='vimdiff '
	echo "second argument is 'vim'; gonna output diff as vimdiff"
elif [[ $# -eq 2 ]]; then
	echo "second argument can be either 'single' or 'vim', see a4db.sh --help"
fi

for stream in 'out' 'err';
do
	diffthis=`$testprogram | grep ".$stream tests/" | cut -d\  -f 2-`
	if [[ -z $diffthis ]]; then continue; fi #continue if empty

	eval "diff -q" $diffthis > /dev/null
	if [[ $? != 0 ]]; then
		echo "std$stream:"
		eval $diffarg $diffthis
	   	echo
	else
		echo "std$stream matches!"
	fi
done
