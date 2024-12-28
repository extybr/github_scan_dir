#!/bin/bash
# $> ./github-scan-dir.sh extybr github_scan_dir

if [ "$#" -ne 2 ]
  then echo -e "\e[37mExpected 2 parameters, but passed $#\e[0m"
  exit 1
fi

USER="$1"
REPO="$2"
URL="https://github.com/$USER/$REPO/"

function request {
url="$1"
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0"
response=$(curl -s --max-time 7 -A "${user_agent}" "${url}")
if ! [[ "${response}" ]]; then
  sleep 3
  request
fi
echo "${response}"
}

function directory {
dir=$(echo $(request "${URL}") | grep -oP "href=\"\/${USER}\/${REPO}\/(blob|tree)[^\"]+\"" | \
sed 's/href="/\\e[37mFile:\\e[0m https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g ; s/%20/ /g ; s/.*tree\/main\//\\e[33mFolder:\\e[0m /' | \
sort | uniq)
echo "${dir}"
}

function sub_directory {
output=$(request "${URL}tree/main/$1")
dir=$(echo "${output}" | grep -oP "href=\"\/${USER}\/${REPO}\/(blob|tree)\/main\/$1[^\"]+\"" | \
sed 's/href="/\\e[37mFile:\\e[0m https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g ; s/%20/ /g ; s/.*tree\/main\//\\e[33mFolder:\\e[0m /' | \
sort | uniq)
echo "${dir}"
}

trees=$(directory)
echo -e "User: \e[37m${USER}\e[0m  Repository: \e[37m${REPO}\e[0m\n${trees}"

for line in $(echo ${trees} | sed 's/\\e\[33mFolder:\\e\[0m /\n/g ; s/\\e\[37mFile:\\e\[0m /\n/g ; s/ /%20/g'); do
  if ! [[ "$line" =~ ^(https) ]]; then
  folder=$(echo "${line}" | sed 's/...$//')
  sub_trees=$(sub_directory "${folder}")
  while ! [[ "$sub_trees" ]]; do
      sleep 2
      sub_trees=$(sub_directory "${folder}")
    done
  space_line=$(echo "${line}" | sed 's/%20/ /g')
  echo -e "  *** \e[33m${space_line}\e[0m ***\n${sub_trees}"
  fi
done

