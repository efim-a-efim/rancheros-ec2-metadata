#!/bin/bash
echo "${1}" | read -t 1 -d ':' label var

if [ -z "${label}" -o -z "${var}" ]; then
  echo "Bad args format"
  exit 1
fi

TAG_VAL=$(aws ec2 describe-tags --region "${AWS_DEFAULT_REGION}" --filters "Name=key,Values=${label}" 2>/dev/null | jq -r -j ".Tags[] | \"\(.Value)\"" 2>/dev/null)

ros config set "rancher.environment.${var}" "${TAG_VAL}"
