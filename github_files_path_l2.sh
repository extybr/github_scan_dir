#!/bin/bash
# ./github_files_path_l2.sh onhexgroup Conferences

user="$1"
repo="$2"
user_agent='Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0'

source ./text-color.sh

response=$(curl -s -A "${user_agent}" "https://api.github.com/repos/${user}/${repo}/contents/")
echo "${response}" | jq -r '.[].path' | nl

# функция выбора
function choice {
output=$(echo "$1" | jq -r '.[].path' | nl | grep -w "$2" | \
         sed "s/ $2%20//g ; s/ /%20/g" | awk '{print $2}')
echo "${output}"
}

echo -ne "${white}Нажмите цифру:${normal} "
read number
git_folder=$(choice "${response}" "${number}")

if ! [[ "${git_folder}" ]]; then
  exit 0
fi

curl -s -A "${user_agent}" "https://api.github.com/repos/${user}/${repo}/contents/${git_folder}?ref=main" | \
jq -r '.[] |.name, .download_url' | sed 'n;G'

