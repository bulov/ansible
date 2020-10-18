#!/bin/bash
#scp myfunc.sh  ${HOST}:/etc/profile.d/
alias  ll='/bin/ls -la'
alias  XD='echo -n "xauth add $(xauth list :${DISPLAY#*:} | tail --line=1 )" | sudo  -i $*'
alias  FC_scan='   N=$(ls  /sys/class/fc_host* | cut -d't' -f 2) ; \
   for i in ${N} ;do echo 1 > /sys/class/fc_host/host${i}/issue_lip ; \
   echo "- - -">/sys/class/scsi_host/host${i}/scan;done'
function SG () { systemctl  | grep  $* ; }
function diG () { ( dig axfr rhc.aero ; dig axfr vr.rhc.aero )   | grep  $* ; }
function SS () { systemctl  status $* ; }
function SR () { systemctl  restart $* ; } 
function kh () { sed -i $1d ~/.ssh/known_hosts ; }
function a () {
Sav=`pwd`
Dir=`dirname $1`
Cop=`basename $1`
( cd $Dir ; tar --acls  -cvzf $Sav/$Cop.tgz $Cop )
}
function aua () {
Dir=`dirname $1`
Cop=`basename $1`
( cd $Dir ; tar --acls  -cvzf - $Cop ) | tar xzv --checkpoint=.1000  -f -
}
function ua () {
Arc=$1
Dir=`dirname $1`
Cop=`basename $1`
Suf=`IFS=. ; set $Cop ; echo $2`
[ _$Suf = _cgz ] && { gzip -d < $Arc | cpio -ivdm  ; exit ; }
tar xzv --checkpoint=.1000  -f $1
}
# User specific environment and startup programs
if [[ $- == *i* ]]
then
    bind '"\e[A": history-search-backward'
    bind '"\e[B": history-search-forward'
fi

