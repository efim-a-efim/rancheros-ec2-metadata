#!/bin/bash
LIB_PATH="/lib/ec2-metadata"

# Basic metadata
export AWS_AVAILABILITY_ZONE="$(wget -O- -q http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)"
export AWS_DEFAULT_REGION="${AWS_AVAILABILITY_ZONE%?}"
export AWS_IAM_ROLE="$(wget -O- -q "http://169.254.169.254/latest/meta-data/iam/info" 2>/dev/null | grep 'InstanceProfileArn' | tr -d ' ",' | cut -d '/' -f 2)"
if [ "${AWS_IAM_ROLE}" ]; then
  export AWS_ACCESS_KEY_ID="$(wget -O- -q "http://169.254.169.254/latest/meta-data/iam/security-credentials/${AWS_IAM_ROLE}" 2>/dev/null | grep 'AccessKeyId' | tr -d ' ",' | cut -d ':' -f 2)"
  export AWS_SECRET_ACCESS_KEY="$(wget -O- -q "http://169.254.169.254/latest/meta-data/iam/security-credentials/${AWS_IAM_ROLE}" 2>/dev/null | grep 'SecretAccessKey' | tr -d ' ",' | cut -d ':' -f 2)"
  export AWS_SECURITY_TOKEN="$(wget -O- -q "http://169.254.169.254/latest/meta-data/iam/security-credentials/${AWS_IAM_ROLE}" 2>/dev/null | grep 'Token' | tr -d ' ",' | cut -d ':' -f 2)"
fi
export AWS_INSTANCE_ID="$(wget -O- -q "http://169.254.169.254/latest/meta-data/instance-id" 2>/dev/null)"

while getopts ':t:e:m' opt; do
  case "$opt" in
    t)
      NEW_CONFIG=`mktemp`
      bash "${LIB_PATH}/ec2-tags.sh" "${AWS_INSTANCE_ID}" "${OPTARG}" | sed 's/^/  /' >> "${NEW_CONFIG}"
      bash "${LIB_PATH}/set-config.sh" < "${NEW_CONFIG}"
      rm "${NEW_CONFIG}"
      ;;
    m)
      NEW_CONFIG=`mktemp`
      bash "${LIB_PATH}/ec2-metadata.sh" | sed 's/^/  /' >> "${NEW_CONFIG}"
      bash "${LIB_PATH}/set-config.sh" < "${NEW_CONFIG}"
      rm "${NEW_CONFIG}"
      ;;
    e)
      NEW_CONFIG=`mktemp`
      bash "${LIB_PATH}/ec2-tag-to-env.sh" "${AWS_INSTANCE_ID}" "${OPTARG}" | sed 's/^/  /' >> "${NEW_CONFIG}"
      bash "${LIB_PATH}/set-config.sh" < "${NEW_CONFIG}"
      rm "${NEW_CONFIG}"
      ;;
    ?)
      echo "Unsupported option -$OPTARG"
      ;;
    :)
      case "$OPTARG" in
        t)
          NEW_CONFIG=`mktemp`
          bash "${LIB_PATH}/ec2-tags.sh" "${AWS_INSTANCE_ID}" 'docker.' | sed 's/^/  /' >> "${NEW_CONFIG}"
          ros config merge < "${NEW_CONFIG}"
          rm "${NEW_CONFIG}"
          ;;
        *)
          echo "Argument required for -$OPTARG"
          ;;
      esac
      ;;
  esac
done
shift $((OPTIND-1))

if [ "${AWS_METADATA_LOAD}" = 'true' ]; then
  NEW_CONFIG=`mktemp`
  bash "${LIB_PATH}/ec2-metadata.sh" | sed 's/^/  /' >> "${NEW_CONFIG}"
  bash "${LIB_PATH}/set-config.sh" < "${NEW_CONFIG}"
  rm "${NEW_CONFIG}"
fi

if [ "${AWS_METADATA_TAG_PREFIXES}" ]; then
  echo "${AWS_METADATA_TAG_PREFIXES}" | while read -d ';' tag; do
    NEW_CONFIG=`mktemp`
    bash "${LIB_PATH}/ec2-tags.sh" "${AWS_INSTANCE_ID}" "${tag}" | sed 's/^/  /' >> "${NEW_CONFIG}"
    ros config merge < "${NEW_CONFIG}"
    rm "${NEW_CONFIG}"
  done
fi

if [ "${AWS_METADATA_TAG_VARIABLES}" ]; then
  echo "${AWS_METADATA_TAG_VARIABLES}" | while read -d ';' tag; do
    NEW_CONFIG=`mktemp`
    bash "${LIB_PATH}/ec2-tag-to-env.sh" "${AWS_INSTANCE_ID}" "${tag}" | sed 's/^/  /' >> "${NEW_CONFIG}"
    bash "${LIB_PATH}/set-config.sh" < "${NEW_CONFIG}"
    rm "${NEW_CONFIG}"
  done
fi
