#!/bin/bash
# ./github_files_path_l2.sh user repository

if [ "$#" -ne 2 ]
  then echo -e "\e[37mExpected 2 parameters, but passed $#\e[0m"
  exit 1
fi

if ! command jq -V &> /dev/null
  then echo -e "\e[37mcommand \e[36mjq\e[37m not found\e[0m"
  exit 1
fi

user="$1"
repo="$2"
user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0'

api_url="https://api.github.com/repos/${user}/${repo}/contents"
response=$(curl -s -A "${user_agent}" "${api_url}")
echo "${response}" | jq -r '.[].path' | nl

# функция выбора
function choice {
output=$(echo "$1" | jq -r '.[].path' | nl | grep -w "$2" | \
         sed "s/ $2%20//g ; s/ /%20/g" | awk '{print $2}')
echo "${output}"
}

echo -ne "\e[37mPress the selected number:\e[0m "
read number
git_folder=$(choice "${response}" "${number}")

if ! [[ "${git_folder}" ]]; then
  exit 0
fi

curl -s -A "${user_agent}" "${api_url}/${git_folder}?ref=main" | \
jq -r '.[] |.name, .download_url' | sed 'n;G'

