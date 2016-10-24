
if [[ $# -eq 0 ]]; then
    echo "You need a test argument bro";
    echo "Usage: a4db [TESTNAME [OPTION]]";
    echo "   or: a4db list;"
    echo "(a4db.sh --help for help)";
    exit;
fi

if [[ $1 = "--help" ]]; then
    echo "Usage: a4db TESTNAME [OPTION]";
    echo "   or: a4db list;"
    echo
    echo "if argument is 'list', a4db.sh will list all possible tests"

    echo "if OPTION is 'valgrind', a4db.sh will print valgrind"
    echo " results into valgrind.out, and then open that file in less"
    echo
    echo "if OPTION is 'single', diff will print in 1 column"
    echo "if OPTION is 'vim', vimdiff will run instead"
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

elif [[ $1 = 'list' ]]; then
    testnames="cat tests/grum.py"
    teamTests=`$testnames | awk '/class Team/,/class Controller/{ if (/def/) {print}}' | sed -r -e 's/.* (.*)\(.*/Team.\1/'`
    contTests=`$testnames | awk '/class Controller/,0{ if (/def/) {print}}' | sed -r -e 's/.* (.*)\(.*/Controller.\1/'`
    echo "$teamTests"
    echo "$contTests"
    #$testprogram | awk 
    exit

fi

testprogram="testa4.sh explain $1"

#get the executable and arguments for that specific test
test=`$testprogram | awk '/.\/2310/'`

if [[ `echo $test | grep \"\" -c` != 0 ]]; then
    $testprogram
    #$testprogram | awk 'NR==7,/Expect exit status/'
    echo ---------------------------------------------------------------------
    echo "can't do anything with this, sorry :("
    exit
fi

testexec=`echo $test | cut -d\  -f 1`
testargs=`echo $test | cut -d\  -f 2- | rev | cut -d\  -f 5- | rev`

#take the arguments and construct a gdb run argument out of them (in gdb.run)
#type 'so[urce] gdb.run' to use it
echo -n 'r ' > ./gdb.run
echo $testargs >> ./gdb.run

if [[ $2 = 'valgrind' ]]; then
>&2 echo "the valgrind option is currently broken. You can run this command yourself though:"
valcommand="valgrind --track-origins=yes $testexec $testargs 2> valgrind.out"
echo $valcommand
#cat valgrind.out

else
    echo $test
    eval $test #run test

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
fi
