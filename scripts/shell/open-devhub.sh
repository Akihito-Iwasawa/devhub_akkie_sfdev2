#!/bin/sh
if [ -z "$DEVHUB_NAME" ]; then
  echo "=============================================="
  echo "
DEVHUB_NAME is not set.
Select from the list and set DEVHUB_NAME.
e.g. export DEVHUB_NAME=devhub
  "
  echo "=============================================="
  sfdx force:alias:list
  exit 1
fi

sfdx force:org:open -u ${DEVHUB_NAME}