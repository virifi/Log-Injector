#!/bin/sh

if [ $# -ne 1 -a $# -ne 3 ]; then
    echo "Usage : $0 <apk_path> <path_to_keystore> <alias_for_keystore_entry>"
    echo "  or"
    echo "Usage : $0 <apk_path>  # only regenerate certificate"
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

tmp_dir=/tmp/sign_apk_sh_tmp
mkdir -p $tmp_dir

unzip $apk_path -d $tmp_dir/unzipped
rm $tmp_dir/unzipped/META-INF/*
7za a -tzip $tmp_dir/tmp.apk $tmp_dir/unzipped/*
if [ $sign -eq 1 ]; then
    jarsigner -keystore $keystore_path $tmp_dir/tmp.apk $alias_for_entry
fi
cp $tmp_dir/tmp.apk $apk_path

rm -rf $tmp_dir
