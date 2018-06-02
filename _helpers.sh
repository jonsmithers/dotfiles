BOLD='\033[1m'
DARKGREY='\033[1;30m'
GREEN='\033[0;32m'
LIGHTGREEN='\033[1;32m'
NORMAL='\033[0m'
RED='\033[0;31m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'
function prompt() {
  read -p "$1 (y/n) " -n 1 -r || exit 1; echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then return 0 # true
  else return 1 # false
  fi
}
function echo_and_run() {
  echo -e "$GREEN`pwd`$WHITE\$ $@" $NORMAL
  "$@" || { echoerr -e $RED"Looks like that didn't work.$YELLOW ¯\_(ツ)_/¯ $NORMAL"; exit 1; }
}
echoerr() { echo "$@" 1>&2; }
