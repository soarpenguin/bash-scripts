#!/usr/bin/env sh

options=()
arguments=()
for arg in "$@"; do
  if [ "${arg:0:1}" = "-" ]; then
    if [ "${arg:1:1}" = "-" ]; then
      options[${#options[*]}]="${arg:2}"
    else
      index=1
      while option="${arg:$index:1}"; do
        [ -n "$option" ] || break
        options[${#options[*]}]="$option"
        let index+=1
      done
    fi
  else
    arguments[${#arguments[*]}]="$arg"
  fi
done

unset count_flag pretty
[ -t 0 ] && [ -t 1 ] && pretty="1"
[ -n "$CI" ] && pretty=""

echo "${options[@]}"

for option in "${options[@]}"; do
  case "$option" in
  "h" | "help" )
    echo help
    #exit 0
    ;;
  "v" | "version" )
    echo version
    #exit 0
    ;;
  "c" | "count" )
    count_flag="-c"
    ;;
  "t" | "tap" )
    pretty=""
    ;;
  "p" | "pretty" )
    pretty="1"
    ;;
  * )
    echo usage >&2
    exit 1
    ;;
  esac
done

if [ "${#arguments[@]}" -eq 0 ]; then
  echo usage >&2
  exit 1
fi
