@echo off
perl lcounter.pl USAGE -path=./lines_counted -rpt=usage_counted.txt
perl lcounter.pl lcounter.pl -path=./lines_counted -rpt=lcounter_counted.txt
