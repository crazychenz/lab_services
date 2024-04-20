#!/bin/sh
# This script is run from act_runner with the following cmd:
# ssh -p 2222 -o StrictHostKeyChecking=no cicd@www.lab /bin/sh < rollout.sh

NOKNOWNHOSTS="-o UserKnownHostsFile=/dev/null"
NOHOSTCHECKS="-o StrictHostKeyChecking=no"
export GIT_SSH_COMMAND="ssh $NOKNOWNHOSTS $NOHOSTCHECKS"

# Assumed that "cicd" user has write permissions to /opt/services
cd /opt/services
if [ ! -e lab_services-config ]; then
  git clone -b deploy git@git.lab:lab/lab_services-config.git
fi
if [ ! -e lab_services-config ]; then
  echo Failed to clone.
  exit 1
fi
cd lab_services-config

# Once we've ensured services exists, let it take the wheel.
./do rollout
