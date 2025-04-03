#!/bin/bash

source ~/p/bash-debugger

library="${library:-"$(ls Libraries | head -1)"}"
term="$(ls Libraries/$library | head -1)"
YELLOW="\e[93m"
RED="\e[91m"
GREEN="\e[92m"
MAGENTA="\e[35m"
NC="\e[0m"

main() {
  while true; do
    echo -en "QDD ${RED}${library}${NC}:${GREEN}${term} ${NC}$ "
    read -n1 mode
    echo
    case "$mode" in
      a)
        ask_mode
        ;;
      q)
        break
        ;;
      t)
        list_terms
        term_mode
        ;;
      y)
        list_libraries
        library_mode
        ;;
      *)
        echo "mode $mode not recognized"
        ;;
    esac
  done
}

#modes

ask_mode() {
  local question_index="${question_index:-0}"
  if [[ "$library" && "$term" ]]; then
    echo -ne "${MAGENTA}QDD ${RED}$library:${GREEN}$term ${YELLOW}[${MAGENTA}$question_index${YELLOW}] ${NC}$ "
    read -n1 command
    case "$command" in 
      \')
        echo
        list_questions
        ;;
      \-)
        echo
        remove_question
        ;;
      i)
        echo
        read -p "Enter question here: " q
        ask_question "$q"
        ;;
    esac
  else
    echo "Library and term must be defined before asking a question (enter term mode with 't' and library mode with 'y')"
  fi
}

library_mode() {
  library_index="$(get_library_index)"
  echo -ne "${RED}QDD $library${NC}:${GREEN}$term ${YELLOW}[${RED}$library_index${YELLOW}] ${NC}$ "
  read -n1 command
  case "$command" in
    [0-9]) 
      echo
      set_library_by_index "$command"
      ;;
    \-)
      echo
      remove_library
      ;;
    i)
      echo
      set_library_by_name
      ;;
  esac
  set_default_term
}

term_mode() {
  term_index="$(get_term_index)"
  echo -ne "${GREEN}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${GREEN}$term_index${YELLOW}] ${NC}$ "
  read -n1 command
  case "$command" in
    [0-9]*) 
      echo
      set_term_by_index "$command"
      ;;
    \-)
      echo
      remove_term $command
      ;;
    i)
      echo
      set_term_by_name
      ;;
  esac
}

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
    lib_index="$(ls Libraries | grep -nw "$library" | sed 's/\(.*\):.*/\1/')"
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
  read -p "Library name: " library_name
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
  read -p "Which library do you want to remove? " lib_choice
  case "$lib_choice" in
    [0-9])
      library_to_remove="$(get_library_by_index "$lib_choice")"
      ;;
  esac
  if [[ "$library_to_remove" ]]; then
    read -n1 -p "Are you sure you want to remove $library_to_remove library? " confirmation
    echo
    if [[ $confirmation == "y" ]]; then
      rm -r Libraries/$library_to_remove && echo "Library removed successfully"
      if [[ $library == $library_to_remove ]]; then
        library=-
      fi
    else
      echo "Ok. Library $library_to_remove is here to stay."
    fi
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
  local i=0
  for lib in Libraries/*; do
    echo "$i - ${lib##*/}"
    (( i++ ))
  done
}

set_default_term() {
  if [[ "$library" ]]; then
    term="$(ls Libraries/$library | head -1)"
    term="${term:--}"
  else
    library="${library:--}"
  fi
}

set_term_by_name() {
  read -p "Enter term here: " term_to_set
  if [[ "$term_to_set" && ! $term_to_set =~ " " ]]; then
    if [[ -d "Libraries/$library/$term_to_set" ]]; then
      term="$term_to_set"
      echo "changed term to $term_to_set"
    else
      mkdir Libraries/$library/$term_to_set
      touch Libraries/$library/$term_to_set/answers
      term="$term_to_set"
      echo "term added"
    fi
  else
    echo "invalid term"
  fi
}

get_term_index() {
  if [[ "$term" != "-" && "$library" != "-" && "$library" && "$term" ]]; then
    term_index="$(ls Libraries/$library | grep -nw "$term" | sed 's/\(.*\):.*/\1/')"
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
  local term_to_remove="$(get_term_to_remove)"
  if [[ "$term_to_remove" ]]; then
    if [[ -d "Libraries/$library/$term_to_remove" ]]; then
      read -n1 -p "Are you sure you want to remove term $term_to_remove? " confirmation
      echo
      if [[ $confirmation == "y" ]]; then
        rm -r Libraries/$library/$term_to_remove && echo "Term removed successfully"
        if [[ $term == $term_to_remove ]]; then
          term=-
        fi
      else
        echo "Ok. Term $term_to_remove is here to stay."
      fi
    else
      echo "Term $term_to_remove not found in $library library"
    fi
  fi
}

get_term_to_remove() {
  local term_to_remove=
  read -n1 -p "Which term do you want to remove? " t_choice
  echo
  case "$t_choice" in
    [0-9])
      term_to_remove="$(get_term_by_index "$t_choice")"
      ;;
    i)
      read -p "Enter term to remove here: " term_to_remove
      ;;
  esac
  echo "$term_to_remove"
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

ask_question() {
  question="$1"
  if [[ "$question" ]]; then
    question_length="$(echo $question | wc -w | sed 's/ *//')"
    if [[ "$question_length" -le 8 ]]; then
      if [[ "$question" =~ "?" ]]; then
        echo "$question" >>Libraries/$library/$term/answers
      else
        echo "$question?" >>Libraries/$library/$term/answers
      fi
      echo "question was added to $term answers"
    else
      echo "Question was $question_length words long. Please make sure questions are <= 8 words long"
    fi
  fi
}

list_questions() {
  local i=0
  while read q; do
    echo "$i - ${q##*/}"
    (( i++ ))
  done < <(cat Libraries/$library/$term/answers)
  if [[ $i == 0 ]]; then
    echo "No questions exist yet for term $term"
  fi
}

remove_question() {
  local question_to_remove=
  if [[ ! "$2" =~ [a-zA-Z] ]]; then
    if [[ "$2" =~ [0-9] ]]; then
      question_index="$2"
    fi
    question_position=$((question_index + 1))
    question_to_remove="$(sed -n "${question_position}p" Libraries/$library/$term/answers)"
    if [[ "$question_to_remove" ]]; then
      read -n1 -p "Are you sure you want to remove the question \"$question_to_remove\" " confirmation
      echo
      if [[ $confirmation == "y" ]]; then
        sed -i '' "/$question_to_remove/d" Libraries/$library/$term/answers && echo "Successfully removed question"
      else
        echo "Ok. No question-removing took place"
      fi
    else
      echo "No question exists yet for $term"
    fi
  else
    echo "Please enter a question index (default is $question_index)"
  fi
}
