#!/bin/bash

ps -eaf | grep dockerd | grep -v grep | awk '{print $2}' | xargs kill -s SIGUSR1
echo t > /proc/sysrq-trigger
journalctl -l > all-journal-`date`.log
dmesg -T > dmesg-`date`.log