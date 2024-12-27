#!/bin/bash
#######################################################
# $> ./github_release_version.sh yt-dlp yt-dlp        #
# $> ./github_release_version.sh ValdikSS GoodbyeDPI  #
#######################################################

if [ "$#" -ne 2 ]
	then echo -e "\e[37mExpected 2 parameters, but passed $#\e[0m"
	exit 1
fi

user="$1"
repo="$2"
version=($(curl -s "https://github.com/${user}/${repo}/releases" | \
           grep -oP "/${user}/${repo}/releases/tag/[^\"]+\"" | \
           sed 's/\"//g'))
echo -e "\e[36mhttps://github.com${version[0]}\e[0m"

