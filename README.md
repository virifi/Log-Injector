#Log Injector

対象のAndroidアプリの全メソッドにLog.dをインジェクトするプログラムです。 
smali/baksmaliのコードをベースにしています。

### 動作環境

以下のコマンドが使用可能なMac or Linux

* java
* jarsigner
* 7za
* unzip

### ダウンロード

* [log-injector-v1.0.0.tar.gz](https://github.com/downloads/virifi/Log-Injector/log-injector-v1.0.0.tar.gz)

### ビルド方法（通常は不要）

```
$ git clone git@github.com:virifi/smali.git
$ cd smali
$ patch -p0 < patches/smali_pom.xml.patch    # Macでビルドする場合
$ patch -p0 < patches/baksmali_pom.xml.patch # 同上
$ mvn package
```
これによって、

* ./smali/target/smali-1.3.4-dev-jar-with-dependencies.jar 
* ./baksmali/target/baksmali-1.3.4-dev-jar-with-dependencies.jar 

が生成される。

### 使用方法

ダウンロードしたアーカイブを任意のディレクトリに解凍し、それに含まれているlog-injector.shを実行。  
ただし、中に含まれている3つのファイル

* log-injector.sh
* smali-1.3.4-dev-jar-with-dependencies.jar
* baksmali-1.3.4-dev-jar-with-dependencies.jar

は同じディレクトリに配置すること。

```
$ log-injector.sh <インジェクト対象のapk> <署名用キーストア> <キーストアエントリーのエイリアス>
```

または

```
$ log-injector.sh <インジェクト対象apk>
```

のように実行する。 
後者の場合、端末にインストールするには次のように署名する必要がある。

```
$ jarsigner -keystore <キーストア> <インジェクト対象apk> <キーストアエントリーのエイリアス> 
```

### 使用例

```
$ ls -l
total 6944
-rw-r--r--  1 virifi  staff    13807  6 26 16:06 Target.apk
-rw-r--r--  1 virifi  staff     1189  6 26 16:06 hogehoge.key
-rw-r--r--  1 virifi  staff  3532236  6 26 16:06 log-injector-v1.0.0.tar.gz
$ tar xzvf log-injector-v1.0.0.tar.gz
x log-injector/
x log-injector/baksmali-1.3.4-dev-jar-with-dependencies.jarx log-injector/log-injector.sh
x log-injector/smali-1.3.4-dev-jar-with-dependencies.jar
$ ls -l log-injector
total 7656
-rw-r--r--  1 virifi  staff  1466324  6 26 13:28 baksmali-1.3.4-dev-jar-with-dependencies.jar
-rwxr-xr-x  1 virifi  staff     2516  6 26 15:44 log-injector.sh
-rw-r--r--  1 virifi  staff  2446518  6 26 13:28 smali-1.3.4-dev-jar-with-dependencies.jar
$ ./log-injector/log-injector.sh
Usage : ./log-injector/log-injector.sh <apk_path> <path_to_keystore> <alias_for_keystore_entry>
   or
Usage : ./log-injector/log-injector.sh <apk_path>  # don't sign
$ ./log-injector/log-injector.sh Target.apk hogehoge.key hogehoge_alias
. . . 省略. . .
$ adb install -r Target.apk
$ adb logcat -s smali  # インジェクトしたLogは「smali」タグで出力される
D/smali   (12012): Lnet/virifi/android/target/MainActivity;-><init>()V
D/smali   (12012): Lnet/virifi/android/target/MainActivity;->onCreate(Landroid/os/Bundle;)V
D/smali   (12012): Lnet/virifi/android/target/Utils;->hogehoge()V
...
$ adb logcat -s smali| perl -MTime::Piece -pe 's/^.*:/localtime->strftime("%F %T")/e' | tee log.txt
2012-06-26 12:12:27 Lnet/virifi/android/target/MainActivity;-><init>()V
2012-06-26 12:12:27 Lnet/virifi/android/target/MainActivity;->onCreate(Landroid/os/Bundle;)V
2012-06-26 12:12:28 Lnet/virifi/android/target/Utils;->hogehoge()V
...
# Logが出力された時間を表示し、標準出力とlog.txtに同時に書き出す。
# ある操作を行う前の時間を記憶しておき、その時間の直後のLogを見ることにより 
# その操作の後、アプリ内のどの部分が働いているかをある程度把握することができる。
```

### ライセンス
```
/* 
 * Copyright (C) 2012 virifi 
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); 
 * you may not use this file except in compliance with the License. 
 * You may obtain a copy of the License at 
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0 
 * 
 * Unless required by applicable law or agreed to in writing, software 
 * distributed under the License is distributed on an "AS IS" BASIS, 
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
 * See the License for the specific language governing permissions and 
 * limitations under the License. 
*/
````
