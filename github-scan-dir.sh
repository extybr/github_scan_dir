#!/bin/bash
# $> ./github-scan-dir.sh extybr github_scan_dir

user="$1"
repo="$2"

function request {
url="https://github.com/$1/$2/"
user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0"
output=$(curl -s -A "${user_agent}" --max-time 3 "${url}")
if ! [[ "${output}" ]]; then
  echo "timeout"
  sleep 3
  request "$1" "$2"
fi
echo "${output}"
}

out=$(request "${user}" "${repo}")
echo "${out}" | grep -oP "href=\"\/${user}\/${repo}\/(blob|tree)[^\"]+\"" | \
sed 's/href="/File: https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g ; s/.*tree\/main\//\Folder: /' | \
sort | uniq

