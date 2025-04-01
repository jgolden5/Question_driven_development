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
    else
      echo "mode $mode not recognized"
    fi
  done
  unset a, ask_question
}

#modes

ask_mode() {
  if [[ "$library" && "$term" ]]; then
    echo -ne "QDD $library:${GREEN}$term ${YELLOW}[$index] ${NC}(ASK): $question?"
    #...
  else
    echo "Library and term must be defined before asking a question (enter term mode with 't' and library mode with 'y')"
  fi
}

library_mode() {
  library_index="$(get_library_index)"
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
      set_library_by_name "$command"
      ;;
  esac
  set_default_term
}

term_mode() {
  term_index="$(get_term_index)"
  echo -ne "${GREEN}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${GREEN}$term_index${YELLOW}] ${NC}$ "
  read command
  case "$command" in
    [0-9]*) 
      set_term_by_index "$command"
      ;;
    \')
      list_terms
      ;;
    \-*)
      remove_term $command
      ;;
    *)
      set_term_by_name "$command"
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

get_library_index() {
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
      library="${lib##*/}"
      break
    else
      (( i++ ))
    fi
  done
}

get_library_by_index() {
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

set_library_by_name() {
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
      library_to_remove="$(get_library_by_index "$2")"
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
    lib_cut="${lib##*/}"
    echo "$i - $lib_cut"
    (( i++ ))
  done
}

set_default_term() {
  term="$(ls Libraries/$library | head -1)"
  term="${term:--}"
}

set_term_by_name() {
  local new_term="$1"
  if [[ "$new_term" ]]; then
    if [[ -d "Libraries/$library/$new_term" ]]; then
      term="$new_term"
      echo "changed term to $new_term"
    else
      mkdir Libraries/$library/$new_term
      touch Libraries/$library/$new_term/answers
      term="$new_term"
      echo "term added"
    fi
  fi
}

get_term_index() {
  if [[ "$term" != "-" && "$library" != "-" && "$library" && "$term" ]]; then
    term_index="$(ls Libraries/$library | grep -n "$term" | sed 's/\(.*\):.*/\1/')"
    (( term_index-- ))
  else
    term_index=0
  fi
  echo "$term_index"
}

set_term_by_index() {
  local index_from_input="$1"
  local i=0
  for t in Libraries/$library/*; do
    if [[ "$i" == "$index_from_input" ]]; then
      term="${t##*/}"
      break
    else
      (( i++ ))
    fi
  done
}

list_terms() {
  if [[ "$(ls Libraries/$library)" ]]; then
    i=0
    for t in Libraries/$library/*; do
      t_cut="${t##*/}"
      echo "$i - $t_cut"
      (( i++ ))
    done
  else
    echo "Library $library does not have any terms yet. You can add some if you'd like!"
  fi
}

remove_term() {
  local term_to_remove=
  if [[ "$2" ]]; then
    if [[ "$2" =~ [a-zA-Z] ]]; then
      term_to_remove="$(get_term_to_remove_by_name "$2")"
    else
      term_to_remove="$(get_term_by_index "$2")"
    fi
  else
    term_to_remove="$term"
  fi
  read -n1 -p "Are you sure you want to remove term $term_to_remove? " confirmation
  echo
  if [[ $confirmation == "y" ]]; then
    rm -r Libraries/$library/$term_to_remove
    if [[ "$term" == "$term_to_remove" ]]; then
      term=-
    fi
  else
    echo "Ok. Library $term_to_remove is here to stay."
  fi
}

get_term_to_remove_by_name() {
  if [[ -d Libraries/$library/"$1" ]]; then
    echo "$1"
  else
    echo ""
    echo "Term $1 does not exist in library $library" >&2
    return 1
  fi
}

get_term_by_index() {
  local index_from_input="$1"
  local i=0
  for t in Libraries/$library/*; do
    if [[ "$i" == "$index_from_input" ]]; then
      echo "${t##*/}"
      break
    else
      (( i++ ))
    fi
  done
}
