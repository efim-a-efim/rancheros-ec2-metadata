# AWS EC2 Metadata provider for RancherOS

Intended to use with Autoscaling.
- Adds AWS EC2 metadata to RancherOS environment
- Adds instance tags (filtered) to Docker options

## How to use

```
#cloud-config
rancher:
  services:
    aws-metadata:
    image: deadroot/rancheros-ec2-metadata
    command: -m -t 'com.'
    privileged: true
    labels:
      io.rancher.os.after: network
      io.rancher.os.scope: system
      io.rancher.os.reloadconfig: 'true'
      io.rancher.os.createonly: 'false'
    volumes:
      - /usr/bin/ros:/bin/ros:ro
      - /var/lib/rancher/conf:/var/lib/rancher/conf:rw
```

### Options:
* `-m` - put AWS metadata to the Rancher environment vars. Metadata supported:
 * AWS_AVAILABILITY_ZONE
 * AWS_DEFAULT_REGION
 * AWS_IAM_ROLE
 * AWS_ACCESS_KEY_ID
 * AWS_SECRET_ACCESS_KEY
 * AWS_SECURITY_TOKEN
 * AWS_INSTANCE_ID
 * AWS_AMI_ID
 * AWS_AMI_LAUNCH_INDEX
 * AWS_AMI_MANIFEST_PATH
 * AWS_ANCESTOR_AMI_IDS
 * AWS_HOSTNAME
 * AWS_LOCAL_HOSTNAME
 * AWS_INSTANCE_ACTION
 * AWS_INSTANCE_TYPE
 * AWS_LOCAL_IPV4
 * AWS_PUBLIC_IPV4
 * AWS_SECURITY_GROUPS
* `-t [prefix]` - load EC2 instance tags starting with `prefix` and add them as labels to docker daemon options
