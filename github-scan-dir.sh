#!/bin/bash

user="$1"
repo="$2"

url="https://github.com/${user}/${repo}/"
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"
curl -s -A "${user_agent}" "${url}" | grep -oP "href=\"\/${user}\/${repo}\/blob[^\"]+\"" | \
sed 's/href="/https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g'

