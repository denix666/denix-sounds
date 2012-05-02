Installation from yum repository
================================

Fedora `12-15` - install the denix repo.

Fedora `16` - install the denix-x repo.

You can install denix-sounds using the yum program (or it's GUI, Package Manager). Make sure you enabled the DeniX repository and type the following as root:

```vim
#yum install denix-sounds
```


Manual RPM installation
=======================

If you want to install this package manualy, download the latest version from one of my mirrors:

http://mirror.os.vc/denix-repo/yum/base/x1

and install it by using this command as root:

```vim
#rpm -ivh denix-sounds.xx.x-xx.x1.noarch.rpm
```


Howto build RPM from source
===========================

Clone my git repository and run the build script:

```vim
$mkdir git-repos
$cd git-repos
$git clone https://github.com/denix666/denix-sounds.git
$cd denix-sounds
$./build_denix-sounds.sh
```
