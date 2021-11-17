#!/bin/sh

sfdx force:alias:list

# input alias-name or user-name
echo
read -p "組織のエイリアス名またはユーザ名を入力: " ORG_NAME

read -n1 -p "削除してよろしいですか (y/N): " yn
if [[ $yn = [yY] ]]; then
  echo  org:delete -u ${ORG_NAME}
  sfdx force:org:delete -u ${ORG_NAME}; sfdx force:org:list --clean
fi