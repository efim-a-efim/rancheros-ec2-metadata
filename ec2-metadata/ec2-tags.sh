#!/bin/bash
INSTANCE="${1}"
TAG="${2:-com.}"
OPTS=$(ros config get rancher.docker.args | grep -v '^\s*$' | grep -v '^$' | while read m opt; do echo -n "'${opt}',"; done)
AWS_OPTS=$(aws ec2 describe-tags --region "${AWS_DEFAULT_REGION}" --filters "Name=resource-id,Values=${INSTANCE}" 2>/dev/null | jq -r -j ".Tags[] | select(.Key|startswith(\"${TAG}\")) | \" '--label','\(.Key)=\(.Value)',\"" 2>/dev/null)
ros config set rancher.docker.args "[ ${OPTS%?}, ${AWS_OPTS%?} ]"
