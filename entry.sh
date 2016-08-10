#!/bin/bash
LIB_PATH="/lib/ec2-metadata"

# Basic metadata
export AWS_AVAILABILITY_ZONE=`wget -O- -q http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null`
export AWS_DEFAULT_REGION="${AWS_AVAILABILITY_ZONE%?}"
export AWS_IAM_ROLE=`wget -O- -q "http://169.254.169.254/latest/meta-data/iam/info" 2>/dev/null | grep 'InstanceProfileArn' | tr -d ' ",' | cut -d '/' -f 2`
if [ "${AWS_IAM_ROLE}" ]; then
  export AWS_ACCESS_KEY_ID=`wget -O- -q "http://169.254.169.254/latest/meta-data/iam/security-credentials/${AWS_IAM_ROLE}" 2>/dev/null | grep 'AccessKeyId' | tr -d ' ",' | cut -d ':' -f 2`
  export AWS_SECRET_ACCESS_KEY=`wget -O- -q "http://169.254.169.254/latest/meta-data/iam/security-credentials/${AWS_IAM_ROLE}" 2>/dev/null | grep 'SecretAccessKey' | tr -d ' ",' | cut -d ':' -f 2`
  export AWS_SECURITY_TOKEN=`wget -O- -q "http://169.254.169.254/latest/meta-data/iam/security-credentials/${AWS_IAM_ROLE}" 2>/dev/null | grep 'Token' | tr -d ' ",' | cut -d ':' -f 2`
fi
export AWS_INSTANCE_ID=`wget -O- -q "http://169.254.169.254/latest/meta-data/instance-id" 2>/dev/null`

while getopts ':t:m' opt; do
  case "$opt" in
    t)
      "${LIB_PATH}/ec2-tags.sh" "${AWS_INSTANCE_ID}" "${OPTARG}"
      ;;
    m)
      "${LIB_PATH}/ec2-metadata.sh" "rancher.environment"
      ;;
    ?)
      echo "Unsupported option -$OPTARG"
      ;;
    :)
      case "$OPTARG" in
        t)
          "${LIB_PATH}/ec2-tags.sh" "${AWS_INSTANCE_ID}" ''
          ;;
        *)
          echo "Argument required for -$OPTARG"
          ;;
      esac
      ;;
  esac
done
shift $((OPTIND-1))
