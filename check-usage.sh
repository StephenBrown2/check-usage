#!/bin/bash

directory="*"
defaultdirectory=1
folderdepth="1"
defaultfolderdepth=1
list="10"
defaultlist=1
pattern="G"
defaultpattern=1
onefilesystem=0
fs=""
debug=0

displayhelp ()
{
    echo "Usage: check-usage.sh [-s <Start directory>] [-d <Depth>] [-n <# to list>] [-p <File pattern>] [-x (One file system)]"
    echo "       check-usage.sh -v  (Displays version and exits)"
    echo "       check-usage.sh -h  (Shows this message)"
}

displayversion ()
{
    echo "  Version 1.0.0, 4/28/2011, written by: Stephen Brown II"
    echo "  Thank you for using this script. I hope you like it."
    echo "  If you have any improvements, please let me know!"
}

while getopts ":s:d:n:p:xvh" option; do
         case $option in
                 s)	directory=$OPTARG
			defaultdirectory=0
			;;
                 d)	folderdepth=$OPTARG
			defaultfolderdepth=0
			;;
                 n)	list=$OPTARG
			defaultlist=0
			;;
                 p)	pattern=$OPTARG
			defaultpattern=0
			;;
                 h)	displayhelp
			exit 1
			;;
                 v)	displayversion
			exit 1
			;;
                 x) onefilesystem=1
                        fs="-x"
                        ;;
                 \?)	echo "Invalid option: -$OPTARG" >&2
			displayhelp
			exit 1
			;;
                 :) echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
         esac
done

if [ $# == 0 ]; then
    alldefaults=1
    displayhelp
fi

if [[ defaultdirectory -eq 1 ]]
    then echo "Using default start directory $directory"
    else echo "Searching in $directory"
fi

if [[ defaultfolderdepth -eq 1 ]]
    then echo "Using default folder depth of $folderdepth"
    else echo "Using a max depth of $folderdepth folders"
fi

if [[ defaultlist -eq 1 ]]
    then echo "Using default output of $list lines max"
    else echo "Displaying a max of $list lines"
fi

if [[ defaultpattern -eq 1 ]]
    then echo "Searching for big folders (>1G)"
    else echo "Listing directories matching '$pattern'"
fi

if [[ onefilesystem -eq 1 ]]
    then echo "Restricting search to a single file-system"
fi

if [[ debug -eq 1 ]]
    then echo "du $fs --max-depth=$folderdepth -k $directory | sort -nr | cut -f2 | xargs -d '\n' du -sh $fs | grep $pattern | head -n $list"
fi

# Run the command
commandoutput=$(du $fs --max-depth=$folderdepth -k $directory | sort -nr | cut -f2 | xargs -d '\n' du -sh $fs | grep $pattern | head -n $list | nl -w 2 -s ':  ')

# Figure out how many lines we've got
linesfound=$(echo -e "$commandoutput" | wc -l)

if [[ $linesfound -eq 0 ]]
then echo "No results found! Try your search again."
    if [[ alldefaults -ne 1 ]]
        then displayhelp
    fi
    exit 1
fi

echo -e "$commandoutput\n"

echo -n "Would you like to look at one of these folders(y/n)? "

read lookdetail
while true; do
    case $lookdetail in
        [yY]*)  break;;
        [nN]*)  exit 0;;
            *)  echo "Please enter yes or no!"
                read lookdetail;;
    esac
done

echo -n "Please enter the line number of the folder to look at: "
read detail
while [ $detail -gt $linesfound ]; do
        echo -n "Sorry, please pick a number less than $linesfound: "
        read detail
done
detail=$detail'p'

# Grab just the folder we want to look at
folderdetail=$(echo -e "$commandoutput" | sed -n $detail | cut -f 2)

echo -e "\n$folderdetail\n"

ls --color -FAShs $folderdetail
