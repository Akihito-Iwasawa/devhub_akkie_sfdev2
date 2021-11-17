#!/bin/sh

# -----------------------------------------------------------------------------
# --- error handling
# -----------------------------------------------------------------------------

set -e
trap catch ERR
function catch {
    if [ -e "./config/project-scratch-def.json" ]; then
      rm ./config/project-scratch-def.json
    fi
}

# -----------------------------------------------------------------------------
# --- start
# -----------------------------------------------------------------------------

echo "[$(date '+%Y-%m-%dT%H:%M:%S')] start: create scratch org."

# -----------------------------------------------------------------------------
# --- validate
# -----------------------------------------------------------------------------

# salesforce CLIが使えない場合はエラー
if !(type "sfdx" > /dev/null 2>&1); then
  echo "Please install sfdx. e.g. yarn add sfdx-cli -g"
  exit 1
fi

# SFDX_LOCAL_NAMEが指定されていない場合はエラー
if [ -z "$SFDX_LOCAL_NAME" ]; then
  echo "Please set a local name with the email of the tambourine. e.g. export SFDX_LOCAL_NAME=akihito.iwasawa"
  exit 1
fi

# DevHub組織が認証できてない、aliasにDevHubを含まない(大文字小文字の区別はしない)場合はエラー
if [ `sfdx force:alias:list | grep DevHub -i | wc -m` = 0 ]; then
  echo "Please authenticate to DevHub-org. Also, include DevHub in the alias. e.g. sfdx force:auth:web:login -d -a DevHub"
  exit 1
fi

# -----------------------------------------------------------------------------
# --- create scratch org
# -----------------------------------------------------------------------------

# スクラッチ組織作成の事前処理
NOW=`date '+%Y%m%d%H%M%S'`
NAME=$SFDX_LOCAL_NAME

# メールアドレスのローカル名+YmdHMSでエイリアスのメールアドレスの文字列を作成
SCRATCH_ORG_NAME=`echo "__your_name__+__now__@tam-bourine.co.jp" | sed -e "s/__your_name__+__now__/${NAME}+${NOW}/g"`

# MyScratch-YmdHMSでエイリアスを設定
SCRATCH_ORG_ALIAS=`echo "MyScratch-__now__" | sed -e "s/__now__/${NOW}/g"`

# devhub組織の一覧を配列で取得
STR_ALIAS_LIST=`sfdx force:alias:list | grep DevHub -i`
IFS=$'\n' ALIAS_LIST=(${STR_ALIAS_LIST})

# 認証したdevhub組織が1つならその値で設定。そうでなければ選択させる
SELECTED_DEVHUB=""
if [ ${#ALIAS_LIST[*]} = 1 ]; then
  IFS=$' ' arr=(${ALIAS_LIST[0]})
  SELECTED_DEVHUB=${arr[0]}
else
  echo "===================================="
  echo "Please select an index by number."
  echo "===================================="
  select value in "${ALIAS_LIST[@]}";
  do
    echo "selected: $value";
    IFS=$' ' arr=(${value})
    SELECTED_DEVHUB=${arr[0]}
    break
  done
fi

# スクラッチ組織定義ファイルの作成
#複数置換 sed 's/XXXXXXX/string1/g;s/YYYYY/string2/g;s/ZZZZZZZ/string3/g')
sed -e "s/__account-info__/${SCRATCH_ORG_NAME}/g" ./config/project-scratch-def.base.json > ./config/project-scratch-def.json

# スクラッチ組織の作成
echo "[$(date '+%Y-%m-%dT%H:%M:%S')] Create ScratchOrg. DevHubOrg:${SELECTED_DEVHUB} ScratchOrg:${SCRATCH_ORG_ALIAS} ..."
sfdx force:org:create -f ./config/project-scratch-def.json --setdefaultusername -a ${SCRATCH_ORG_ALIAS} --targetdevhubusername ${SELECTED_DEVHUB} --durationdays 30

# 作成したスクラッチ組織にパスワードを設定
echo "[$(date '+%Y-%m-%dT%H:%M:%S')] Generate ScratchOrg password. DevHubOrg:${SELECTED_DEVHUB} ScratchOrg:${SCRATCH_ORG_ALIAS} ..."
sfdx force:user:password:generate -u ${SCRATCH_ORG_ALIAS}

# 作成したスクラッチ組織の情報をバックアップとして生成
echo "[$(date '+%Y-%m-%dT%H:%M:%S')] Create ScratchOrg-info-file. DevHubOrg:${SELECTED_DEVHUB} ScratchOrg:${SCRATCH_ORG_ALIAS} ..."
sfdx force:user:display -u ${SCRATCH_ORG_ALIAS} --json > "./config/${SCRATCH_ORG_ALIAS}.json"
echo "===================================="
echo "Successfully!!"
echo "===================================="
sfdx force:user:display -u ${SCRATCH_ORG_ALIAS} --json

# 初回のソースプッシュを行う
echo "[$(date '+%Y-%m-%dT%H:%M:%S')] Execute source push. DevHubOrg:${SELECTED_DEVHUB} ScratchOrg:${SCRATCH_ORG_ALIAS} ..."
sfdx force:source:push -u ${SCRATCH_ORG_ALIAS} -f

# 作成したスクラッチ組織を開く
sfdx force:org:open -u ${SCRATCH_ORG_ALIAS}