#!/bin/sh

usage() {
  echo "Possible Targets:"
  echo "- start - docker compose up"
  echo "- stop - docker compose down"
  echo "- restart - stop & start"
  echo "- pull - repull images"
  echo "- rollout - pull && start"
  echo "- deploy - git checkout/merge/push in deploy"
  exit 1
}

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
    docker compose pull
    ;;

  rollout)
    ./do pull && ./do start
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
