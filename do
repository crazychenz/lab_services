#!/bin/sh


usage() {
  echo "Possible Targets:"
  echo "- help - this help"
  echo "- start - docker compose up"
  echo "- stop - docker compose down"
  echo "- restart - stop & start"
  echo "- pull - repull images"
  echo "- build - build all images"
  echo "- initial - build & start initial services"
  echo "- rollout - git-pull & pull & start"
  echo "- deploy - git checkout/merge/push in deploy"
  exit 1
}

NOKNOWNHOSTS="-o UserKnownHostsFile=/dev/null"
NOHOSTCHECKS="-o StrictHostKeyChecking=no"
export GIT_SSH_COMMAND="ssh $NOKNOWNHOSTS $NOHOSTCHECKS"

if [ $# -lt 1 ]; then
  usage
fi

DO_CMD=$1
WD=$(pwd)

case $DO_CMD in

  start)
    docker compose up -d
    ;;

  stop)
    docker compose down
    ;;

  restart)
    ./do stop ; ./do start
    ;;

  pull)
    docker compose -f upstream-docker-compose.yml pull
    ;;
  
  build)
    docker compose -f initial-docker-compose.yml build
    ;;
  
  initial)
    ./do build
    docker compose -f initial-docker-compose.yml up -d
    ;;

  rollout)
    # Update any service descriptor updates.
    git pull
    # Note: You must manually do a docker login for
    ./do build && ./do pull && ./do start
    # Optional commands for cleaner (or more aggressive) maintenance.
    # docker compose up --force-recreate --build -d
    # docker image prune -f
    ;;

  deploy)
    # Guard against dirty repos.
    git status 2>/dev/null | grep "nothing to commit" || exit 1
    git checkout deploy || git checkout -b deploy
    git merge main
    git push origin deploy
    git checkout main
    ;;

  *)
    usage
    ;;
esac
