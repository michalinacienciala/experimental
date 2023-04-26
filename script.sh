#!/bin/sh  

if [[ $SUCC_COMMAND == "0" ]];
then
  echo "Success"
  exit 0
elif [[ $SUCC_COMMAND == "1" ]];
then
  echo "Error creating pull request: Unprocessable Entity (HTTP 422)"
  echo "A pull request already exists for michalinacienciala:auto-update-api-docs-3."
  exit 1
else
  exit 2
fi