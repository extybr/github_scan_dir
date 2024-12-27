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
response=$(curl -s -A "${user_agent}" --max-time 3 "${url}")
if ! [[ "${response}" ]]; then
  echo "timeout"
  sleep 3
  request "$1" "$2"
fi
echo "${response}"
}

output=$(request "${user}" "${repo}")
dir=$(echo "${output}" | grep -oP "href=\"\/${user}\/${repo}\/(blob|tree)[^\"]+\"" | \
sed 's/href="/\\e[37mFile:\\e[0m https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g ; s/%20/ /g ; s/.*tree\/main\//\\e[33mFolder:\\e[0m /' | \
sort | uniq)

echo -e "User: \e[37m${user}\e[0m  Repository: \e[37m${repo}\e[0m\n${dir}"

