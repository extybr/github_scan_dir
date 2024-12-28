#!/bin/bash
# $> ./github-scan-dir.sh extybr github_scan_dir

if [ "$#" -ne 2 ]
  then echo -e "\e[37mExpected 2 parameters, but passed $#\e[0m"
  exit 1
fi

user="$1"
repo="$2"

function request {
url="https://github.com/$1/$2/"
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0"
response=$(curl -s --max-time 7 -A "${user_agent}" "${url}")
if ! [[ "${response}" ]]; then
  sleep 3
  request "$1" "$2"
fi
echo "${response}"
}

function directory {
output=$(request "$1" "$2")
dir=$(echo "${output}" | grep -oP "href=\"\/$1\/$2\/(blob|tree)[^\"]+\"" | \
sed 's/href="/\\e[37mFile:\\e[0m https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g ; s/%20/ /g ; s/.*tree\/main\//\\e[33mFolder:\\e[0m /' | \
sort | uniq)
echo "${dir}"
}

function sub_directory {
output=$(request "$1" "$2/tree/main/$3")
dir=$(echo "${output}" | grep -oP "href=\"\/$1\/$2\/(blob|tree)\/main\/$3[^\"]+\"" | \
sed 's/href="/\\e[37mFile:\\e[0m https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g ; s/%20/ /g ; s/.*tree\/main\//\\e[33mFolder:\\e[0m /' | \
sort | uniq)
echo "${dir}"
}

trees=$(directory "${user}" "${repo}")
echo -e "User: \e[37m${user}\e[0m  Repository: \e[37m${repo}\e[0m\n${trees}"

for line in $(echo ${trees} | sed 's/\\e\[33mFolder:\\e\[0m /\n/g ; s/\\e\[37mFile:\\e\[0m /\n/g ; s/ /%20/g'); do
  if ! [[ "$line" =~ ^(https) ]]; then
  sub_trees=$(sub_directory "${user}" "${repo}" $(echo "${line}" | sed 's/...$//'))
  space_line=$(echo "${line}" | sed 's/%20/ /g')
  echo -e "  *** \e[33m${space_line}\e[0m ***\n${sub_trees}"
  fi
done

