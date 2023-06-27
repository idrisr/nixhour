#!/usr/bin/env bash

echo -e "${PATH//:/\\n}"
curl https://api.github.com/users/idrisr | jq .id
