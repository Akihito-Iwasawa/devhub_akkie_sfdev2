#!/bin/sh

# -----------------------------------------------------------------------------
# 指定した組織からログアウト
# -----------------------------------------------------------------------------

# alias確認
sfdx force:alias:list

# input alias-name or user-name
echo "\n"
echo "Warning!======================================"
echo "
If you logout of a scratch-org that
does not have a password,
you will not be able to login again.

Please check your password.
e.g. sfdx force:user:display -u org

If you do not have a password, please set one.
e.g. sfdx force:user:password:generate -u org
"
echo "=============================================="
echo "\n"

read -p "組織のエイリアス名またはユーザ名を入力: " ORG_NAME

echo  auth:logout -u ${ORG_NAME}

sfdx force:auth:logout -u ${ORG_NAME}