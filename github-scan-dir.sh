#!/bin/bash
# $> ./github-scan-dir.sh extybr github_scan_dir

if [ "$#" -ne 2 ]
  then echo -e "\e[37mExpected 2 parameters, but passed $#\e[0m"
  exit 1
fi

USER="$1"
REPO="$2"
URL="https://github.com/$USER/$REPO/"
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0"
HREF="href=\"\/${USER}\/${REPO}\/(blob|tree)"
SED_STR='s/href="/\\e[37mFile:\\e[0m https:\/\/raw.githubusercontent.com/g ; s/blob\///g ; s/.$//g ; s/%20/ /g ; s/.*tree\/main\//\\e[33mFolder:\\e[0m /'

function request {
response=$(curl -s --max-time 7 -A "${USER_AGENT}" "$1")
echo "${response}"
}

function directory {
output=$(request "$1")
dir=$(echo "${output}" | grep -oP "$2" | sed "${SED_STR}" | sort | uniq)
echo "${dir}"
}

trees=$(directory "${URL}" "${HREF}[^\"]+\"")
echo -e "User: \e[37m${USER}\e[0m  Repository: \e[37m${REPO}\e[0m\n${trees}"

sed_str_sub='s/\\e\[33mFolder:\\e\[0m /\n/g ; s/\\e\[37mFile:\\e\[0m /\n/g ; s/ /%20/g'
for line in $(echo ${trees} | sed "${sed_str_sub}"); do
  if ! [[ "$line" =~ ^(https) ]]; then
  folder=$(echo "${line}" | sed 's/...$//')
  GREP_STR="${HREF}\/main\/${folder}[^\"]+\""
  sub_trees=$(directory "${URL}tree/main/${folder}" "${GREP_STR}")
  while ! [[ "$sub_trees" ]]; do
      sleep 1
      sub_trees=$(directory "${URL}tree/main/${folder}" "${GREP_STR}")
    done
  space_line=$(echo "${line}" | sed 's/%20/ /g')
  echo -e "  *** \e[33m${space_line}\e[0m ***\n${sub_trees}"
  fi
done

