#!/usr/local/bin/bash

source ~/p/bash-debugger

library="${library:-"$(ls Libraries | head -1)"}"
term="$(ls Libraries/$library | head -1)"
YELLOW="\e[93m"
RED="\e[91m"
GREEN="\e[92m"
MAGENTA="\e[35m"
ORANGE="\e[38;5;214m"
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
        term_mode
        ;;
      w)
        answer_mode
        ;;
      y)
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
  list_questions
  answers_length="$(cat Libraries/$library/$term/answers | wc -l | sed 's/ *//')"
  if [[ "$answers_length" -eq 0 ]]; then
    question_index=0
  elif [[ ! "$question_index" ]]; then
    question_index="$(( answers_length - 1 ))"
  fi
  if [[ "$library" && "$term" ]]; then
    echo -ne "${MAGENTA}QDD ${RED}$library:${GREEN}$term ${YELLOW}[${MAGENTA}$question_index${YELLOW}] ${NC}$ "
    read -n1 command
    echo
    case "$command" in 
      \-)
        list_questions
        read -p "Warning: Questions should typically be removed by replacing them with new questions. Please enter the index of the question you want to remove: " question_index
        remove_question_at_index "$question_index"
        ;;
      e)
        read -p "Enter question here: " q
        ask_question "$q"
        ;;
      q|'')
        ;;
      *)
        echo "command not recognized"
        ;;
    esac
  else
    echo "Library and term must be defined before asking a question (enter term mode with 't' and library mode with 'y')"
  fi
}

term_mode() {
  term_index="$(get_term_index)"
  list_terms
  echo -ne "${GREEN}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${GREEN}$term_index${YELLOW}] ${NC}$ "
  read -n1 command
  echo
  case "$command" in
    [0-9]*) 
      set_term_by_index "$command"
      ;;
    \-)
      remove_term $command
      ;;
    e)
      set_term_by_name
      ;;
    q|'')
      ;;
    *)
      echo "command not recognized"
      ;;
  esac
}

answer_mode() {
  list_answers
  echo -ne "${ORANGE}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${ORANGE}$question_index${YELLOW}] ${NC}$ "
  read -n1 command
  echo
  case "$command" in 
    [0-9])
      answer_question_at_index "$command"
      ;;
    '')
      if [[ "$question_index" ]]; then
        answer_question_at_index "$question_index"
      else
        answer_question_at_index "0"
      fi
      ;;
    \-)
      remove_answer
      ;;
    q)
      ;;
    *)
      echo "Command not recognized"
      ;;
  esac
}

library_mode() {
  library_index="$(get_library_index)"
  list_libraries
  echo -ne "${RED}QDD $library${NC}:${GREEN}$term ${YELLOW}[${RED}$library_index${YELLOW}] ${NC}$ "
  read -n1 command
  echo
  case "$command" in
    [0-9]) 
      set_library_by_index "$command"
      ;;
    \-)
      remove_library
      ;;
    e)
      set_library_by_name
      ;;
    q|'')
      ;;
    *)
      echo "command not recognized"
      ;;
  esac
  set_default_term
}

alias qdd='source qdd.sh && echo qdd sourced successfully'

#utils -- auxiliary functions used for main and mode functions

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
      library_index=$index_from_input
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
    if [[ $i == $library_index ]]; then
      echo "$i - ${lib##*/} *"
    else
      echo "$i - ${lib##*/}"
    fi
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
      term_index=$index_from_input
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
      if [[ $i == $term_index ]]; then
        echo "$i - $t_cut *"
      else
        echo "$i - $t_cut"
      fi
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
    e)
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
  local question="$1"
  if [[ "$question" ]]; then
    local question_length="$(echo $question | wc -w | sed 's/ *//')"
    if [[ "$question_length" -le 8 ]]; then
      local answers_length="$(cat Libraries/$library/$term/answers | wc -l | sed 's/ *//')"
      echo "$question" >>Libraries/$library/$term/answers && echo "question was added to $term answers"
      if (( answers_length + 1 > 8 )); then
        questions_exceed_8=t
        while [[ $questions_exceed_8 == t ]]; do
          list_questions
          read -n1 -p "Number of $term questions exceeds 8. Choose a question to replace: " replacement_index
          echo
          remove_question_at_index "$replacement_index" && questions_exceed_8=f
        done
      fi
    else
      echo "Question was $question_length words long. Please make sure questions are <= 8 words long"
    fi
  fi
}

list_questions() {
  local i=0
  while read line; do
    question="$(echo "$line" | sed 's/\(.*\?\).*/\1/')"
    echo "$i - $question"
    (( i++ ))
  done < <(cat Libraries/$library/$term/answers)
  if [[ $i == 0 ]]; then
    echo "No questions exist yet for term $term"
  fi
}

remove_question_at_index() {
  question_index="$1"
  if [[ "$question_index" && ! "$question_index" =~ [a-zA-Z] ]]; then
    question_position=$((question_index + 1))
    question_to_remove="$(get_question_by_index "$question_index")"
    if [[ "$question_to_remove" ]]; then
      read -n1 -p "Are you sure you want to remove the question \"$question_to_remove\" " confirmation
      echo
      if [[ $confirmation == "y" ]]; then
        sed -i '' "/$question_to_remove/d" Libraries/$library/$term/answers && echo "Successfully removed question at index $question_index"
      else
        echo "Ok. No question removing took place"
        return 1
      fi
    else
      echo "No question exists yet for $term"
      return 1
    fi
  else
    echo "No question index was entered"
    return 1
  fi
}

get_question_by_index() {
  question_index="$1"
  question_position="$(( question_index + 1 ))"
  sed -n "${question_position}p" Libraries/$library/$term/answers | sed 's/\(.*\?\).*/\1/'
}

answer_question_at_index() {
  question_index="$1"
  local question_position="$(( question_index + 1 ))"
  local question="$(sed -n "${question_position}p" Libraries/$library/$term/answers)"
  read -p "$question " answer
  if [[ "$answer" ]]; then
    local answer_length="$(echo "$answer" | wc -w | sed 's/ *//')"
    if (( "$answer_length" > 8 )); then
      echo "Answer was $answer_length words long. Please make sure answers are <= 8 words long (note that I may add up to 8 answers per question)." && return 1
    else
      answer="${answer^}"
      sed -i '' "${question_position}s/$/ $answer./" Libraries/$library/$term/answers && echo "Answer successfully added"
    fi
  else
    echo "Empty answer" && return 1
  fi
}

list_answers() {
  local i=0
  while read line; do
    question="$(sed 's/\(.*\?\).*/\1/' <<<"$line")"
    echo "$i - $question"
    local j=-1
    while read inner_line; do
      if (( j > -1 )); then
        echo "  $j - $inner_line"
      fi
      (( j++ ))
    done < <(sed 's/\([\!\.\?]\) \([A-Z]\)/\1\n\2/g' <<<"$line")
    (( i++ ))
  done < <(cat Libraries/$library/$term/answers)
  if [[ $i == 0 ]]; then
    echo "No answers exist yet for term $term"
  fi
}

remove_answer() {
  list_questions_that_have_answers
  read -n1 -p "Which question do you want to remove an answer from? " q_index
  echo
  if [[ "$valid_question_indices" =~ $q_index ]]; then
    list_answers_for_question_at_index $q_index
    read -n1 -p "Which answer do you want to remove from said question? (* removes all answers) " a_index
    echo
    if [[ $q_index =~ [0-9] ]]; then
      if [[ $a_index == "*" ]]; then
        remove_all_answers_at_question_index "$q_index"
      else
        remove_answer_by_indices "$q_index" "$a_index"
      fi
    else
      echo "Invalid q index"
    fi
  else
    echo "No answers exist yet for question at index $q_index"
  fi
}

list_answers_for_question_at_index() {
  local q_index="$1"
  local q_position="$(( q_index + 1 ))"
  local line="$(sed -n "${q_position}p" Libraries/$library/$term/answers)"
  local question="$(sed 's/\(.*\?\).*/\1/' <<<"$line")"
  echo "$q_index - $question"
  local j=-1
  while read inner_line; do
    if (( j > -1 )); then
      echo "  $j - $inner_line"
    fi
    (( j++ ))
  done < <(sed 's/\([\!\.\?]\) \([A-Z]\)/\1\n\2/g' <<<"$line")
}

remove_answer_by_indices() {
  q_index="$1"
  a_index="$2"
  q_position="$(( q_index + 1 ))"
  line="$(sed -n "${q_position}p" Libraries/$library/$term/answers)"
  question="$(get_question_by_index $q_index)"
  if [[ "$line" == "$question" ]]; then
    echo "No answer exists for question yet"
  else
    answer_to_remove=
    local j=-1
    while read inner_line; do
      if [[ $j == $a_index ]]; then
        answer_to_remove="$inner_line"
        break
      fi
      (( j++ ))
    done < <(sed 's/\([\!\.\?]\) \([A-Z]\)/\1\n\2/g' <<<"$line")
    if [[ "$answer_to_remove" ]]; then
      sed -i '' "s/ $answer_to_remove//" Libraries/$library/$term/answers && echo "Answer \"$answer_to_remove\" was removed successfully"
      question_index="$(( question_index - 1 ))"
    else
      echo "Answer index was invalid. No answer was removed"
    fi
  fi
}

list_questions_that_have_answers() {
  valid_question_indices=
  local i=0
  while read line; do
    question="$(echo "$line" | sed 's/\(.*\?\).*/\1/')"
    if [[ "$question" != "$line" ]]; then
      echo "$i - $question"
      valid_question_indices+="$i"
    fi
    (( i++ ))
  done < <(cat Libraries/$library/$term/answers)
  if [[ $i == 0 ]]; then
    echo "No questions exist yet for term $term"
  fi
}

remove_all_answers_at_question_index() {
  q_index="$1"
  q_position="$(( q_index + 1 ))"
  sed -i '' "${q_position}s/\(.*\?\).*/\1/" "Libraries/$library/$term/answers" && echo "Successfully removed all answers from question \"$question\""
}

