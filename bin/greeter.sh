#!/bin/bash

set -e

name="${1}"

if [ -z "$name" ]
then
  printf "You are awesome!\n"
else
  printf "Hello %s, you are awesome!\n" ${name}
fi