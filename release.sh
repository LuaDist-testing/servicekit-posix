#!/bin/sh

#
# Near-automatic releases.
#


if [ -z "$1" ]
  then
	echo "Usage: release.sh [version] [release]"
	exit 1
  fi

if [ -z "$2" ]
  then
	echo "Usage: release.sh [version] [release]"
	exit 1
  fi
  
VERSION=$1
RELEASE=$2


echo "======"
echo "Export Without SVN"
echo "======"

rm -rf /tmp/servicekit-release
mkdir /tmp/servicekit-release
cd /tmp/servicekit-release

svn export svn+ssh://aaron@syn.zadzmo.org/home/aaron/repos/servicekit-posix \
	./servicekit-posix-$VERSION 	|| exit 1

cd servicekit-posix-$VERSION
  

#
# Unfortunately, no test suite
#
#echo "======"
#echo "Running tests"
#echo "======"

#./test.lua || exit 1


echo "======"
echo "Check Version Number"
echo "======"

v1=`lua ./printver.lua`
v2="$VERSION `date +%Y.%m%d`"

echo $v1
echo $v2

if [ "$v1" != "$v2" ]
  then
	echo "Version number not right!"
	exit 1
  fi


echo "======"
echo "Generate Docs"
echo "======"

ldoc.lua . || exit 1


echo "======"
echo "Rockspec handling"
echo "======"

sed -ie "s/%VERSION%/$VERSION/g" servicekit-posix.rockspec 	|| exit 1
sed -ie "s/%RELEASE%/$RELEASE/g" servicekit-posix.rockspec	|| exit 1


echo "======"
echo "Tarball"
echo "======"

cd ..
tar -cvf servicekit-posix-$VERSION.tar servicekit-posix-$VERSION
gzip -9 servicekit-posix-$VERSION.tar

cp servicekit-posix-$VERSION/servicekit-posix.rockspec servicekit-posix-$VERSION-$RELEASE.rockspec
