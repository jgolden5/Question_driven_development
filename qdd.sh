#!/bin/bash

source ~/p/bash-debugger

library="${library:--}"
term="${term:--}"
index=0
YELLOW="\e[93m"
RED="\e[91m"
GREEN="\e[92m"
NC="\e[0m"

main() {
  while true; do
    echo -en "QDD ${RED}${library}${NC}:${GREEN}${term} ${NC}$ "
    read -n1 mode
    echo
    if [[ "$mode" == a || "$mode" == t || "$mode" == y ]]; then
      eval "$mode"
    elif [[ "$mode" == q ]]; then
      break
    fi
  done
  unset a, ask_question
}

ask_mode() {
  if [[ "$library" && "$term" ]]; then
    echo -ne "QDD $library:${GREEN}$term ${YELLOW}[$index] ${NC}(ASK): $question?"
    #...
  else
    echo "Library and term must be defined before asking a question (enter term mode with 't' and library mode with 'y')"
  fi
}

library_mode() {
  index="$(get_index_from_library)"
  echo -ne "${RED}QDD $library ${NC}[$index] $ "
  read command
  case "$command" in
    *)
      if [[ -d "Libraries/$command" ]]; then
        library="$command"
        echo "changed library to $command"
      else
        echo "library $command not recognized"
      fi
      ;;
  esac
}

alias a=ask_mode
alias t=term_mode
alias y=library_mode
alias qdd='source qdd.sh && echo qdd sourced successfully'

#util functions (operative functions of the main functions)

get_questions() {
  questions=
  while read question; do
    questions+="$question"$'\n'
  done < <(cat "Libraries/$library/$term/answers" | sed 's/\(.*\)\?.*/\1/')
  echo -n "$questions"
}

get_index_from_library() {
  if [[ "$library" != "-" ]]; then
    lib_index="$(ls Libraries | grep -n "$library" | sed 's/\(.*\):.*/\1/')"
    (( lib_index-- ))
  else
    echo "library is not set yet, therefore, index defaults to 0."
    lib_index=0
  fi
  echo "$lib_index"
}

