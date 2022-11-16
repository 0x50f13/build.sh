#!/usr/bin/env bash

# Update path
export PATH=$PATH:/bin/:/sbin/:/usr/sbin/:/usr/bin/

# shopt
shopt -s nullglob

# Set basedir
BASEDIR=`pwd`

# Colors
if test -t 1; then
    HAS_COLORS=true
    bold=$(tput bold)
    normal=$(tput sgr0)
    red=$(tput setaf 1)
    green=$(tput setaf 2)
    blue=$(tput setaf 4)
    yellow=$(tput setaf 11)
else
    HAS_COLORS=false
    echo "[!]: No colors will be available: not supported."
fi

error(){
  if $HAS_COLORS; then
    echo "${bold}${red}==> ${normal}${@}"
  else
    echo "[-]: ${@}"
  fi
}

success(){
  if $HAS_COLORS; then
    echo "${bold}${green}==> ${normal}${@}"
  else
    echo "[+]: ${@}"
  fi
}

warn(){
  if $HAS_COLORS; then
    echo "${bold}${yellow}=> ${normal}${@}"
  else
    echo "[!]: ${@}"
  fi
}

info(){
  if $HAS_COLORS; then
    echo "${bold}${blue}=> ${normal}${@}"
  else 
    echo "[*]: ${@}"
  fi
}

exec(){
    info "${@}"
    eval "${@}"
    code=$?
    if [ ! $code -eq 0 ]; then
        error "Exec: ${@} failed with non-zero exit code: ${code}"
        exit -1
    fi
}

require_directory(){ # Creates directory if not exist
    if [ ! -d $1 ]; then
        warn "Directory not found: ${1}. Will create it now."
        exec "mkdir -p ${1}"
    fi
}

change_dir(){
    if [ ! -d $1 ]; then
        error "No such directory: ${1}"
        exit -1
    fi
    info "Entering directory: ${1}"
    cd $1
}

leave_dir(){
    info "Leaving directory: $(pwd)"
    cd "$BASEDIR"
}

check_equal(){
    printf "${bold}${blue}=> ${normal}Checking equality: ${1} and ${2}..."
    if ! cmp $1 $2 >/dev/null 2>&1
    then
      printf "${bold}${red}FAILED${normal}\n"
      return -1
    fi
    printf "${bold}${green}OK${normal}\n"
    return 0
}

define(){
  eval "$1=$2"
}

def(){          
  return `[[ -v $1 ]]`
}

ndef(){
  return `[[ ! -v $1 ]]`
}

undef_fn(){
  unset -f $1
}

pass(){
  :
}

sundef_fn(){
  eval "function $1 { 
           pass 
        }"
}

include(){
    if [ -f "$1" ]; then
      source "$1"
    else
      error "Failed to include file: $1"
      exit -1
    fi
}

include_if_exists(){
    if [ -f "$1" ]; then
       source "$1"
    fi
}

require_equal(){
    check_equal $1 $2
    local r=$?
    if [ ! $r -eq 0 ]; then
       error "Files ${1} and ${2} are not equal."
       exit -1
    fi
}

check_command(){
    printf "${bold}${blue}=> ${normal}Checking that ${1} avail..."
    if ! [ -x "$(command -v ${1})" ]; then
      printf "${bold}${red}FAILED${normal}\n"
      return -1
    fi
    printf "${bold}${green}OK${normal}\n"
    return 0
}

require_command(){
    check_command $1
    local r=$?
    if [ ! $r -eq 0 ]; then
       error "Command ${1} is not avail."
       exit -1
    fi
}

require_root(){
    if [ "$EUID" -ne 0 ]; then 
      error "Root is required to run this build"
      exit -1
    fi
}

# $1 -- pattern
# $2 -- target
copy(){
  BUILDSH_MOVE_LIST=($1)
  for f in "${BUILDSH_MOVE_LIST[@]}"
  do
    exec "cp $f $2"
  done
}


# $1 -- pattern
# $2 -- target
move(){
  BUILDSH_MOVE_LIST=($1)
  for f in "${BUILDSH_MOVE_LIST[@]}"
  do
    exec "cp $f $2"
  done
}

if [ -f "$BASEDIR/Buildfile" ]; then
   source "$BASEDIR/Buildfile"
else
   error "Buildfile not found in local directory!"
   exit -1
fi


if [ $# -eq 0 ]; then
    error "Please specify target. Use -h option for help."
    exit -1
fi

if [[ $1 == "-h" ]]; then
    echo "Usage:"$0" <-h> $USAGE"
    echo "-h        Display this help message and exit."
    exit 0
fi

if [[ `type -t "target_${1}"` == "function" ]]; then
     eval "target_${1}"
     success "Done."
else
     error "No such target:${1}."
fi
