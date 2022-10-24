#!/usr/bin/env bash

#CONSTANTS
FILE="/tmp/foobar"

#### common functions
function remove_file() {
    chmod 700 $FILE
    rm -rf $FILE
    if ! [ $? -eq 0 ]; then
        echo "REMOVING OF FILE FAILED"
        sleep 1
    fi

    if [ -e $FILE"_link" ]; then
        rm -rf $FILE"_link" 
        if ! [ $? -eq 0 ]; then
            echo "REMOVING OF LINK FAILED"
            sleep 1
        fi
    fi

    return 0
}


# functions OK
function var_ok() {
    echo "Foo=15" > $FILE
    return 0
}
function var_ok_spaces() {
    echo "Foo = 15" > $FILE
    return 0
}
function var_ok_tabs() {
    echo -e "Foo\t=\t15" > $FILE
    return 0
}
function var_ok_multiple() {
    echo "Foo=15" > $FILE
    echo "FooBar=5" >> $FILE
	echo "Bar=hello world" >> $FILE
    return 0
}
function var_ok_multiple2() {
    echo "Foo=5" > $FILE
    echo "FooBar=5" >> $FILE
	echo "Bar=hello world" >> $FILE
    echo "Foo=15" >> $FILE
    return 0
}
function var_ok_comment() {
    echo "Foo=5" > $FILE
    echo "#Foo=5" >> $FILE
    echo "Foo=15" >> $FILE
    return 0
}
function var_ok_binary_chars() {
    echo -n -e "\\x48\\x00\\x49\\x00\\n" > $FILE
    echo "Foo=15" >> $FILE
    return 0
}
function var_ok_rights_r() {
    echo "Foo=15" > $FILE
	chmod 400 $FILE
    return 0
}
function var_ok_link() {
    echo "Foo=15" > $FILE"_link"
    ln -s $FILE"_link" $FILE
    return 0
}


# functions NOK
function var_nok() {
    echo "Foo=5" > $FILE
    return 0
}

function var_nok_spaces() {
    echo "Foo = 5" > $FILE
    return 0
}
function var_nok_tabs() {
    echo -e "Foo\t=\t5" > $FILE
    return 0
}
function var_nok_empty() {
    rm -f $FILE &> /dev/null
    touch $FILE
    return 0
}
function var_nok_string() {
    echo "Foo=5ABC" > $FILE
    return 0
}

function var_nok_multiple() {
    echo "Foo=5" > $FILE
    echo "FooBar=5" >> $FILE
	echo "Bar=hello world" >> $FILE
    return 0
}
function var_nok_multiple2() {
    echo "Foo=15" > $FILE
    echo "FooBar=5" >> $FILE
	echo "Bar=hello world" >> $FILE
    echo "Foo=5" >> $FILE
    return 0
}
function var_nok_multiple3() {
    echo "Foo=15          Foo=5" > $FILE
    echo "FooBar=5" >> $FILE
	echo "Bar=hello world" >> $FILE
    echo "Foo=5" >> $FILE
    return 0
}
function var_nok_comment() {
    echo "Foo=25" >> $FILE
    echo "Foo=5" >> $FILE
    echo "#Foo=15" >> $FILE
    return 0
}
function var_nok_comment2() {
    echo "#   Foo=25" >> $FILE
    return 0
}
function var_nok_dos_format() {
    echo "Foo=5" > $FILE
    echo "FooBar=5" >> $FILE
	echo "Bar=hello world" >> $FILE
    echo "Foo=15" >> $FILE
	sed -i -e 's/\r*$/\r/' $FILE
    return 0
}
function var_nok_binary_chars() {
    echo -n -e "\\x48\\x00\\x49\\x00\\n" > $FILE
    echo "Foo=5" >> $FILE
    return 0
}
function var_nok_rights_r() {
    echo "Foo=15" > $FILE
	chmod 100 $FILE
    return 0
}
function var_nok_directory() {
    mkdir $FILE
    return 0
}
function var_nok_link() {
    mkdir $FILE"_link"
    ln -s $FILE"_link" $FILE
    return 0
}


#import testing fuction
source my_functions

########################## script core

#scenarios to be OK
arr_ok=(`declare -F | awk '$NF~/^var_ok/{print $NF}'`)
nr_ok_pass=0
nr_ok_fail=0

echo -e "\n\n"
echo "TESTING OK SCENARIOS"
sleep 1

for fun in "${arr_ok[@]}"
do
    #prepare $FILE content
    echo "Running scenario: $fun"
    $fun
    #run rest
    foobar_foo_gte_10 &> /dev/null
    
    if [ $? -eq 0 ]; then
        echo "TEST OK"
        nr_ok_pass=$((nr_ok_pass+1))
    else
        echo "TEST FAILED on scenario $fun !!!"
        nr_ok_fail=$((nr_ok_fail+1))
        sleep 1
    fi

    remove_file
  
done

#scenarios to be NOK
arr_nok=(`declare -F | awk '$NF~/^var_nok/{print $NF}'`)
nr_nok_pass=0
nr_nok_fail=0

echo -e "\n\n"
echo "TESTING NOK SCENARIOS"
sleep 1

for fun in "${arr_nok[@]}"
do
    #prepare $FILE content
    echo "Running scenario: $fun"
    $fun
    #run rest
    foobar_foo_gte_10 &> /dev/null
    
    if [ $? -eq 1 ]; then
        echo "TEST OK"
        nr_nok_pass=$((nr_nok_pass+1))
    else
        echo "TEST FAILED on scenario $fun !!!"
        nr_nok_fail=$((nr_nok_fail+1))
        sleep 1
    fi

	remove_file

  
done

#summary
echo -e "\n\n"
echo "---------------------- SUMMARY OF RESULTS ----------------------"
echo ""
printf "OK scenarios:\nNR_PASS: %20s    NR_FAILED: %20s\n" $nr_ok_pass $nr_ok_fail
echo ""
printf "NOK scenarios:\nNR_PASS: %20s    NR_FAILED: %20s\n" $nr_nok_pass $nr_nok_fail
