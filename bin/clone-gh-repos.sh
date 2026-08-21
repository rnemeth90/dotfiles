#!/bin/bash

repos="$@"

for i in $repos;do
  echo "Cloning $i"

  # check if the repo already exists
  if [ -d "$i" ]; then
    echo -e "\033[33mRepo $i already exists, skipping...\033[0m"
    continue
  fi
    

  git clone git@github.com:aprimo-org/$i.git
  if [ $? -ne 0 ]; then
    echo -e "\033[31mFailed to clone $i\033[0m"
    continue
  fi
done
