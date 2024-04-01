#!/bin/bash
Usage () {

 echo -ne "
Please set correct Parameters
Anzahl Paramter = $#"
echo $*
echo $0
echo $1
echo $2

}


checkParams () {
if [[ $# -eq 0 ]] 
  then
    echo "$* $0 $1 $2"
    Usage $* $0 $1 $2
fi
}

clear
set -a

echo $*
echo $0

echo -ne "
_______________________________________

     Patty's Arch install script

_______________________________________"
checkParams $* $0 $1 $2
