#!/bin/sh

processing
sleep 5
/usr/bin/pkill java 
sleep 6
/home/tangibledisplay/sketchbook/sonart/application.linux/sonart &

rm -f /home/tangibledisplay/hs_err_pid*.log
rm -f /home/tangibledisplay/processing-1.2.1/hs_err_pid*.log

