#!/usr/bin/python3
# ./github-user-repository.py extybr
# API rate limit !!

import asyncio
import httpx
import sys

normal = "\033[0m"
yellow = "\033[33m"
blue = "\033[36m"
white = "\033[37m"

if len(sys.argv) == 2:
    USER = sys.argv[1]
else:
    print(f"{white}Expected 1 parameters\nExample: \n{yellow}"
          f"./github-user-repository.py extybr{normal}")
    exit(0)


async def api_request() -> None:
    async with httpx.AsyncClient() as client:
        url = 'https://api.github.com/users/{}'.format(USER)
        user_data = await client.get(url)
        repos = user_data.json()['repos_url']
        repos_data = await client.get(repos)
        for repository in repos_data.json():
            print(blue, repository['name'], normal)


if __name__ == '__main__':
    asyncio.run(api_request())

