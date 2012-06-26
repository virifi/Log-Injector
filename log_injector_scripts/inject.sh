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


base_dir=`dirname $0`

function abs_path()
{
    abspath=$(cd $(dirname $1) && pwd)/$(basename $1)
    echo $abspath
}

apk_path=`abs_path $1`
if [ $sign -eq 1 ]; then
    keystore_path=`abs_path $2`
    alias_for_entry=$3
fi

smali_jar=`abs_path $base_dir/smali-1.3.4-dev-jar-with-dependencies.jar`
baksmali_jar=`abs_path $base_dir/baksmali-1.3.4-dev-jar-with-dependencies.jar`
sign_apk=`abs_path $base_dir/sign_apk.sh`

tmp_dir=/tmp/inject_logd_sh_tmp
start_dir=`pwd`
mkdir -p $tmp_dir
cp $apk_path $tmp_dir/tmp.apk

cd $tmp_dir
java -jar $baksmali_jar tmp.apk -o injected_smalis
java -jar $smali_jar  injected_smalis -o classes.dex
7za d -tzip tmp.apk classes.dex
7za a -tzip tmp.apk classes.dex
if [ $sign -eq 1 ]; then
    $sign_apk tmp.apk $keystore_path $alias_for_entry
else
    $sign_apk tmp.apk
fi
cp tmp.apk $apk_path
cd $start_dir

rm -rf $tmp_dir
