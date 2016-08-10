# AWS EC2 Metadata provider for RancherOS

Intended to use with Autoscaling.
- Adds AWS EC2 metadata to RancherOS environment
- Adds instance tags (filtered) to Docker options

## How to use

{code}
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

{code}

### Options:
* `-m` - put AWS metadata to the Rancher environment vars
* `-t [prefix]` - load EC2 instance tags starting with `prefix` and add them as labels to docker daemon options
