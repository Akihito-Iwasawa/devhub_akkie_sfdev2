#!/bin/sh
if [ -z "$SCRATCH_ORG_NAME" ]; then
  echo "=============================================="
  echo "
SCRATCH_ORG_NAME is not set.
Select from the list and set SCRATCH_ORG_NAME.
e.g. export SCRATCH_ORG_NAME=MyScratch
  "
  echo "=============================================="
  sfdx force:alias:list
  exit 1
fi

sfdx force:org:open -u ${SCRATCH_ORG_NAME}