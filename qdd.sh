#!/bin/bash

source ~/p/bash-debugger

library="${library:-"$(ls Libraries | head -1)"}"
term="$(ls Libraries/$library | head -1)"
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
  library_index="$(get_index_from_library)"
  echo -ne "${RED}QDD $library ${YELLOW}[${RED}$library_index${YELLOW}] ${NC}$ "
  read command
  case "$command" in
    [0-9]*) 
      set_library_by_index "$command"
      ;;
    \')
      list_libraries
      ;;
    \-*)
      remove_library $command
      ;;
    *)
      set_library_manually "$command"
      ;;
  esac
  set_default_term
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
    lib_index=0
  fi
  echo "$lib_index"
}

set_library_by_index() {
  local index_from_input="$1"
  local i=0
  for lib in Libraries/*; do
    if [[ "$i" == "$index_from_input" ]]; then
      library="${lib#*/}"
      break
    else
      (( i++ ))
    fi
  done
}

get_library_from_index() {
  local index_from_input="$1"
  local i=0
  for lib in Libraries/*; do
    if [[ "$i" == "$index_from_input" ]]; then
      echo "${lib#*/}"
      break
    else
      (( i++ ))
    fi
  done
}

set_library_manually() {
  local library_name="$1"
  if [[ "$library_name" ]]; then
    if [[ -d "Libraries/$library_name" ]]; then
      library="$library_name"
      echo "changed library to $library_name"
    else
      read -n1 -p "library $library_name not recognized. Would you like to add it? " add_library_confirmation
      echo
      if [[ "$add_library_confirmation" =~ y|Y ]]; then
        mkdir Libraries/$library_name
        library="$library_name"
        set_default_term
        echo "library added"
      else
        echo "Ok. Back to business, then."
      fi
    fi
  fi
}

remove_library() {
  local library_to_remove=
  if [[ "$2" ]]; then
    if [[ "$2" =~ [a-zA-Z] ]]; then
      library_to_remove="$(get_library_to_remove_by_name "$2")"
    else
      library_to_remove="$(get_library_from_index "$2")"
    fi
  else
    library_to_remove="$library"
  fi
  read -n1 -p "Are you sure you want to remove library $library_to_remove? " confirmation
  echo
  if [[ $confirmation == "y" ]]; then
    rm -r Libraries/$library_to_remove
  else
    echo "Ok. Library $library_to_remove is here to stay."
  fi
}

get_library_to_remove_by_name() {
  if [[ -d Libraries/"$1" ]]; then
    echo "$1"
  else
    echo ""
    echo "Library $1 does not exist" >&2
    return 1
  fi
}

list_libraries() {
  i=0
  for lib in Libraries/*; do
    lib_cut="${lib#*/}"
    echo "$i - $lib_cut"
    (( i++ ))
  done
}

set_default_term() {
  term="$(ls Libraries/$library | head -1)"
  term="${term:--}"
}

