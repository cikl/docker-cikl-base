#!/bin/bash
set -e

function die {
  echo "ERROR: $@"
  exit 1
}


if [ "$1" = "" ]; then
  die "no command provided. Use 'help'."
fi

ENTRYPOINT_CMD=$1

function check_for_su {
  if [ "$ENTRYPOINT_USER" = "" ]; then
    die "Cannot drop privileges when ENTRYPOINT_USER environment \
      variable has not been set!"
    exit 1
  fi
}

function do_user_shell {
  check_for_su
  exec gosu $ENTRYPOINT_USER /bin/bash
}

function do_root_shell {
  exec /bin/bash
}

function do_help {
  echo HELP:
  echo "Known commands:"
  echo "   user-shell              - Start a shell as '$ENTRYPOINT_USER'"
  echo "   root-shell              - Start a shell as 'root'"
  echo "   help                    - print useful information and exit"
  echo ""
  echo "Additional commands:"
  ls $ENTRYPOINT_CMD_PATH/

  exit 0
}

if [ ! -d "$ENTRYPOINT_PRE_PATH" ]; then
  die "ENTRYPOINT_PRE_PATH=$ENTRYPOINT_PRE_PATH is not a directory or does not exist!"
fi

for file in "$ENTRYPOINT_PRE_PATH"/*; do
  if [ -f "$file" ]; then
    echo "sourcing: $file"
    source "$file"
  fi
done

if [ "$ENTRYPOINT_CMD" = "user-shell" ]; then
  do_user_shell
elif [ "$ENTRYPOINT_CMD" = "root-shell" ]; then
  do_root_shell
elif [ "$ENTRYPOINT_CMD" = "help" ]; then 
  do_help
elif [ -f "$ENTRYPOINT_CMD_PATH/$ENTRYPOINT_CMD" ]; then
  # Get rid of first argument (it's already ENTRYPOINT_CMD)
  shift
  if [ "$ENTRYPOINT_DROP_PRIVS" = "1" ]; then
    check_for_su
    exec gosu $ENTRYPOINT_USER "$ENTRYPOINT_CMD_PATH/$ENTRYPOINT_CMD" "$@"
  else
    exec "$ENTRYPOINT_CMD_PATH/$ENTRYPOINT_CMD" "$@"
  fi
else
  die "ERROR: unknown command: $@. Use 'help' for info."
fi
