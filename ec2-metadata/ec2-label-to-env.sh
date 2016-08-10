#!/bin/bash
INSTANCE="${1}"
label=$(echo "$2" | cut -d ':' -f 1)
var=$(echo "$2" | cut -d ':' -f 2-)

if [ -z "${label}" -o -z "${var}" ]; then
  echo "Bad args format"
  exit 1
fi

conf_path="rancher.environment.${var}"
[ "$(echo "$var" | grep '\.')" ] && conf_path="$var"

TAG_VAL=$(aws ec2 describe-tags --region "${AWS_DEFAULT_REGION}" --filters "Name=key,Values=${label}" "Name=resource-id,Values=${INSTANCE}" 2>/dev/null | jq -r -j ".Tags[] | \"\(.Value)\"" 2>/dev/null)

ros config set "${conf_path}" "${TAG_VAL}"
