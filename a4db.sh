#!/bin/bash

function DEBUG()
{
    [ "$_DEBUG" == "on" ] &&  $@ 
}

if [[ $# -eq 0 ]]; then
    echo "You need a test argument bro";
    echo "Usage: a4db [TESTNAME [OPTION]]";
    echo "   or: a4db list;"
    echo "   or: a4db test [team|controller];"
    echo "(a4db.sh --help for help)";
    exit;
fi

if [[ $1 = --debug ]]; then
    #debug is a dangerous option, which enables
    #potentially unsafe changes
    echo "WARNING: DEBUG MODE"
    _DEBUG="on"
    shift
fi

case $1 in
--help)
    echo "Usage: a4db [OPTION] TESTNAME";
    echo "   or: a4db list;"
    echo
    echo "Arguments"
    echo "   -s, --single           print diff in 1 column (instead of 2)"
    echo "   -v, --vim              run vimdiff instead of diff"
    echo "   -m, --valgrind         run the test in valgrind & output in less"
    echo
    echo "if argument is 'list', a4db.sh will list all possible tests"
    echo "if argument is 'test', a4db.sh run all tests for team/controller only"
    echo
    echo "1) Run the associated test"
    echo "2) print both the stdout and stderr diffs"
    echo "3) create a GDB source file (gdb.run) containing a gdb"
    echo "run command with appropriate arguments."
    echo "To use gdb.run, boot up GDB with the appropriate executable"
    echo "argument, and then enter the command 'source gdb.run'"
    echo "in place of the regulary 'run' command"
    exit
    ;;

list)
    testnames="cat tests/grum.py"
    teamTests=`$testnames | awk '/class Team/,/class Controller/{ if (/def/) {print}}' | sed -r -e 's/.* (.*)\(.*/Team.\1/'`
    contTests=`$testnames | awk '/class Controller/,0{ if (/def/) {print}}' | sed -r -e 's/.* (.*)\(.*/Controller.\1/'`
    echo "$teamTests" "$contTests"
    #$testprogram | awk 
    exit
    ;;

test)
    testnames="cat tests/grum.py"
    teamTests=`$testnames | awk '/class Team/,/class Controller/{ if (/def/) {print}}' | sed -r -e 's/.* (.*)\(.*/Team.\1/'`
    contTests=`$testnames | awk '/class Controller/,0{ if (/def/) {print}}' | sed -r -e 's/.* (.*)\(.*/Controller.\1/'`
    case $2 in
        team)
            testa4.sh test $teamTests
            ;;
        con*)
            testa4.sh test $contTests
            ;;
        '')
            testa4.sh
            ;;
        *)
            testa4.sh test $2
            ;;
    esac
    exit
    ;;

--single|-s)
    diffarg='diff '
    echo "second argument is 'single'; gonna output diff in one column"
    shift
    ;;

--vim|-v)
    diffarg='vimdiff '
    echo "second argument is 'vim'; gonna output diff as vimdiff"
    shift
    ;;

-m|--valgrind)
    mode="valgrind"
    shift
    ;;

*)
    diffarg='diff -y '
    ;;

esac 



testprogram="testa4.sh explain $1"

#get the executable and arguments for that specific test
test=`$testprogram | awk '/Start/{getline; print;}'`

if [[ `echo "$test" | wc -l` = 1 ]]; then

    # "" has replaced an option in this mode, cannot run
    if [[ `echo $test | grep 'ncserv_port|\"\"' -c` != 0 ]]; then
        $testprogram
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

    if [[ $# -gt 1 ]]; then
        echo "Just in case you didn't know, the way this script works has changed."
        echo "Check out --help to get back on track if need be"

    elif [[ $mode = 'valgrind' ]]; then
        valcommand="valgrind --log-fd=1 --track-origins=yes $testexec $testargs"
        echo $valcommand
        eval $valcommand | less

    else
        echo $test
        eval $test #run test

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

else

    if [[ -z ${_DEBUG} ]]; then
    test="$(echo "$test" | awk '/.\/2310/{print;exit}')"
    echo "$test"
    testexec=`echo $test | cut -d\  -f 1`
    testargs=`echo $test | cut -d\  -f 2- | rev | cut -d\  -f 5- | rev`

    #take the arguments and construct a gdb run argument out of them (in gdb.run)
    #type 'so[urce] gdb.run' to use it
    echo -n 'r ' > ./gdb.run
    echo $testargs >> ./gdb.run

    $testprogram

    echo ---------------------------------------------------------------------
    echo "can't do anything with this, sorry :("
    exit; fi

    firsttest="$(echo "$test" | awk 'NR==1')"

    ftestout="$(echo "$firsttest" | grep -E -o '\S*.out')"
    ftesterr="$(echo "$firsttest" | grep -E -o '\S*.err')"

    #rm -f out.a4db err.a4db
    #mkfifo out.a4db err.a4db
    #firsttest="$(echo "$firsttest" | sed -e "s/$ftestout/out.a4db/g" -e "s/$ftesterr/err.a4db/g")"
    firsttest="$(echo "$firsttest" | sed -e 's/>.*//g')"
    echo $firsttest

    eval $firsttest | awk '{print; exit;}' & echo sdfhaslfjaslfjsadldfsaldjf
    killit=$!
    #$echo "$firsttest" > $ftestout & echo sdfhaslfjaslfjsadldfsaldjf
    portno="$(awk '{print; exit;}' < this.out)"
    echo Portno:
    echo $portno
    othertests="$(echo "$test" | awk '1,0{print;}' | sed -e "s/\"\"\|\[ncserv_port\]/$portno/g")"
    echo "$othertests"
    #test=echo "$othertests" | perl -pe 's/\n/ \&'
    echo "$othertests"
    sleep 3
    kill $(jobs -p)
    
    cat portno.a4db
    rm portno.a4db
    echo tail
    echo $portno
    cat $ftestout
    exit
fi

