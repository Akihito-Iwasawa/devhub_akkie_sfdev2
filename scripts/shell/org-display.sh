#!/bin/sh

# -----------------------------------------------------------------------------
# 指定した組織の詳細情報を参照
# -----------------------------------------------------------------------------

# alias確認
sfdx force:alias:list

# input alias-name or user-name
echo
read -p "組織のエイリアス名またはユーザ名を入力: " ORG_NAME

echo  org:display -u ${ORG_NAME}

sfdx force:org:display -u ${ORG_NAME} --verbose