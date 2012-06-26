#!/bin/sh

if [ $# -ne 1 -a $# -ne 3 ]; then
    echo "Usage : $0 <apk_path> <path_to_keystore> <alias_for_keystore_entry>"
    echo "  or"
    echo "Usage : $0 <apk_path>  # don't sign"
    exit 1
fi

sign=0
if [ $# -eq 3 ]; then
    sign=1
fi

# base directory of script file
base_dir=`dirname $0`

# convert relative path to absolute one
function abs_path()
{
    abspath=$(cd $(dirname $1) && pwd)/$(basename $1)
    echo $abspath
}

# name 
apk_path=`abs_path $1`
if [ $sign -eq 1 ]; then
    keystore_path=`abs_path $2`
    alias_for_entry=$3
fi

# check whether commands exist
if [ ! -x `which unzip` ]; then
    echo "cannot find unzip"
    exit 1
fi
if [ ! -x `which 7za` ]; then
    echo "cannot find 7za"
    exit 1
fi
if [ $sign -eq 1 -a ! -x `which jarsigner` ]; then
    echo "cannot find jarsigner"
    exit 1
fi
if [ ! -x `which java` ]; then
    echo "cannot find java"
    exit 1
fi

# custom smali/baksmali jar path
smali_jar=`abs_path $base_dir/smali-1.3.4-dev-jar-with-dependencies.jar`
baksmali_jar=`abs_path $base_dir/baksmali-1.3.4-dev-jar-with-dependencies.jar`

# check whether jar files exist
if [ ! -e $smali_jar ]; then
    echo "cannot find smali-1.3.4-dev-jar-with-dependencies.jar"
    exit 1
fi
if [ ! -e $baksmali_jar ]; then
    echo "cannot find baksmali-1.3.4-dev-jar-with-dependencies.jar"
    exit 1
fi

# temporary directory
tmp_dir=/tmp/inject_logd_sh_tmp

# remember the current directory so that we can go back lator
start_dir=`pwd`

# copy apk to tmp dir
mkdir -p $tmp_dir
cp $apk_path $tmp_dir/tmp.apk

# now we work in the directory
cd $tmp_dir

# custom baksmali injects Log.d code to all methods
java -jar $baksmali_jar tmp.apk -o injected_smalis
# compile smalis
java -jar $smali_jar  injected_smalis -o classes.dex
# replace classes.dex
7za d -tzip tmp.apk classes.dex
7za a -tzip tmp.apk classes.dex

# temporary directory for sign
tmp_dir_for_sign=/tmp/sign_apk_sh_tmp
mkdir -p $tmp_dir_for_sign

# create certificate
unzip $tmp_dir/tmp.apk -d $tmp_dir_for_sign/unzipped
rm $tmp_dir_for_sign/unzipped/META-INF/*
7za a -tzip $tmp_dir_for_sign/tmp_for_sign.apk $tmp_dir_for_sign/unzipped/*

# sign
if [ $sign -eq 1 ]; then
    jarsigner -keystore $keystore_path $tmp_dir_for_sign/tmp_for_sign.apk $alias_for_entry
fi

# now completed all instructions, so overwrite original apk with finished one
cp $tmp_dir_for_sign/tmp_for_sign.apk $apk_path

# remove tmp dir for sign 
rm -rf $tmp_dir_for_sign

# go back
cd $start_dir

# remove working directory
rm -rf $tmp_dir
