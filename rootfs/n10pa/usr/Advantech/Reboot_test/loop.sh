#!/bin/bash
  
settime=40
pslog=/root/LOG/ps.log
systemctllog=/root/LOG/systemctl.log
systemstatuslog=/root/LOG/systemstatus.log
journallog=/root/LOG/journal.log
testlog=/root/LOG/test.log
ctfile=/root/CONFIG/ct.txt
ct=$(awk '{print int($1)}' $ctfile)
ct=${ct:-0}
mkdir -p /root/{CONFIG,LOG}
echo "=================" >> $pslog
echo "=================" >> $systemctllog
echo "=================" >> $systemstatuslog
echo "=================" >> $journallog
date >> $journallog
journalctl -b -p 3 --no-pager | cut -d " " -f 6- >> $journallog

nw_ping(){
  if ping -W 3 -c 1 8.8.8.8 > /dev/null 2>&1 ; then
    ping_ans="%%% Network is working %%%"
  else
    ping_ans="%%% Network is down %%%"
  fi
  echo $ping_ans >> $testlog
}

while : 
do
  uptime=$(awk '{print int($1)}' /proc/uptime)
  if [ $uptime -gt $settime ] ; then
    ct=$(( $ct + 1 ))
    echo $ct > $ctfile
    echo "=================" >> $testlog
    echo "System Restart [ $ct round ]" >> $testlog
    date >> $testlog
    nw_ping
    sync
    #systemctl reboot
    #strace -o /root/strace.log /sbin/init 6
    #/sbin/init 6
    #systemctl -f reboot
    /sbin/init 6
    #/usr/Advantech/EAPI_test/testdl_wdt -s 1
    exit 0;
  fi
  date >> $pslog
  ps ax >> $pslog
  date >> $systemctllog
  systemctl >> $systemctllog
  date >> $systemstatuslog
  systemctl status >> $systemstatuslog
  sleep 3
done

