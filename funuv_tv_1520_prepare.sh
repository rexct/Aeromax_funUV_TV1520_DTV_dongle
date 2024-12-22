#/bin/bash

echo "clone kernel source code"

UNAMER=`uname -r`
VER="${UNAMER/-/.}"
echo $VER

git clone https://gitlab.archlinux.org/archlinux/packaging/packages/linux.git

cd linux

git checkout $VER

cd ..

echo "Remobe old file"
rm *.zst
rm *.sign
rm linux-*.tar.xz

echo "Copy file"
cp linux/.SRCINFO ./
cp linux/config ./
cp -rf linux/.git ./
cp -rf linux/keys ./

echo "Start diffuse"
diffuse linux/PKGBUILD PKGBUILD 2>/dev/null

echo "Start build"

BUILDDIR=/dev/shm time makepkg

echo "Clean file"
rm *.zst
rm *.sign
rm linux-*.tar.xz
rm -rI linux
