#!/usr/bin/python3
# ./github-scan-dir.py extybr github_scan_dir
# API rate limit !!

import sys
import requests

normal = "\033[0m"
red = "\033[31m"
yellow = "\033[33m"
violet = "\033[35m"
blue = "\033[36m"
white = "\033[37m"

dst = ''
if len(sys.argv) == 3:
    user = sys.argv[1]
    repo = sys.argv[2]
    dst = f"https://api.github.com/repos/{user}/{repo}/contents"
else:
    print(f"{white}Expected 2 parameters\nExample: \n{yellow}"
          f"./github-scan-dir.py extybr playlist_check{normal}")
    exit(0)


def request(url: str) -> dict | None:
    return requests.get(url).json()


def scan(items: list) -> None:
    for item in items:
        if not isinstance(item, dict):
            message = items.get('message')
            print(f"{red}{message}{normal}")
            exit(0)
        item_type = item.get('type', 0)
        name = item.get('name')
        if item_type == 'dir':
            print(f"  {yellow}{name}{normal}")
            if not name.startswith('.'):
                scan(request(item.get('url')))
        elif item_type == 'file':
            print(f"{blue}{name}{normal}")
            download_url = item.get('download_url')
            print(f"{violet}{download_url}{normal}")


scan(request(dst))

