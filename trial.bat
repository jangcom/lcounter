@echo off
rem lcounter source code
perl lcounter.pl lcounter.pl -path=./lines_counted -rpt=lcounter_counted.txt

rem USAGE
perl lcounter.pl USAGE -path=./lines_counted -rpt=usage_counted.txt

rem lcounter source code + USAGE
perl lcounter.pl lcounter.pl USAGE -path=./lines_counted -rpt=lcounter_usage_counted.txt
