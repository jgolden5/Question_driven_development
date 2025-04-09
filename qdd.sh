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
  clear
  while true; do
    echo -en "QDD ${RED}${library}${NC}:${GREEN}${term} ${NC}$ "
    read -n1 mode
    echo
    mode_func="$(choose_mode_func "$mode")"
    eval "$mode_func"
  done
}

#modes

question_mode() {
  safeguard_question_index
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
      [0-9])
        safeguard_question_index "$command" && echo "Question index was changed to $question_index"
        ;;
      \#)
        echo "$(get_question_count) questions for term $term"
        ;;
      a)
        read -p "Enter question here: " q
        ask_question "$q"
        ;;
      d)
        list_questions
        read -n1 -p "Warning: Questions should typically be removed by replacing them with new questions. Please enter the index of the question you want to remove (* removes all): " question_index_input
        echo
        if [[ $question_index_input == '*' ]]; then
          remove_all_questions
        elif [[ $question_index_input =~ [0-9] ]]; then
          remove_question_at_index "$question_index_input"
        elif [[ ! "$question_index_input" ]]; then
          remove_question_at_index "$question_index"
        fi
        ;;
      e)
        local index_of_question_to_edit="$(get_question_to_edit)"
        local question_to_edit="$(get_question_by_index $index_of_question_to_edit)"
        edit_question "$question_to_edit" "$index_of_question_to_edit"
        ;;
      h)
        question_help
        ;;
      x|Q|'')
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
    a)
      set_term_by_name
      ;;
    d)
      remove_term $command
      ;;
    e)
      local index_of_term_to_edit="$(get_term_to_edit)"
      local term_to_edit="$(get_term_by_index $index_of_term_to_edit)"
      edit_term "$term_to_edit"
      ;;
    h)
      term_help
      ;;
    x|Q|'')
      ;;
    *)
      echo "command not recognized"
      ;;
  esac
}

answer_mode() {
  safeguard_question_index
  list_answers_for_question_at_index "$question_index"
  echo -ne "${ORANGE}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${ORANGE}$question_index${YELLOW}] ${NC}$ "
  read -n1 command
  echo
  case "$command" in 
    ''|a)
      if [[ "$question_index" ]]; then
        answer_question_at_index "$question_index"
      else
        answer_question_at_index "0"
      fi
      ;;
    \#)
      echo "$(get_answer_count) answers for term $term"
      ;;
    d)
      remove_answer
      ;;
    e)
      local index_of_answer_to_edit="$(get_answer_to_edit)"
      local answer_to_edit="$(get_answer_by_index $index_of_answer_to_edit)"
      edit_answer "$answer_to_edit" "$index_of_answer_to_edit"
      ;;
    s)
      list_all_answers
      ;;
    h)
      answer_help
      ;;
    x|Q)
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
    a)
      set_library_by_name
      ;;
    d)
      remove_library
      ;;
    e)
      local index_of_library_to_edit="$(get_library_to_edit)"
      local library_to_edit="$(get_library_by_index $index_of_library_to_edit)"
      edit_library "$library_to_edit"
      ;;
    h)
      library_help
      ;;
    x|Q|'')
      ;;
    *)
      echo "command not recognized"
      ;;
  esac
  set_default_term
}

alias qdd='source qdd.sh'
alias qmm='source qdd.sh && main'
alias qvv='vi qdd.sh'

#help functions. These give every possible command I can access from the current state

main_help() {
  echo "Main Help:"
  echo "h/? - main help"
  echo "q - question mode"
  echo "t - term mode"
  echo "w - answer mode"
  echo "x/Q - exit qdd"
  echo "y - library mode"
}

library_help() {
  echo "Library Mode Help:"
  echo "0-9 - set library by index"
  echo "a - add/adjust library by name (multi-char)"
  echo "d - delete library"
  echo "e - edit existing library names"
  echo "h/? - library mode help"
  echo "x/Q/Enter - exit library mode"
}

term_help() {
  echo "Term Mode Help:"
  echo "0-9 - set term by index"
  echo "a - adjust/add term by name (multi-char)"
  echo "d - delete term"
  echo "e - edit existing term names"
  echo "h/? - term mode help"
  echo "x/Q/Enter - exit term mode"
}

question_help() {
  echo "Question Mode Help:"
  echo "0-9 - change question index"
  echo "a - ask question (multi-char)"
  echo "d - delete question by index"
  echo "e - edit existing quesions"
  echo "h/? - question mode help"
  echo "x/Q/Enter - exit question mode"
}

answer_help() {
  echo "Answer Mode Help:"
  echo "0-9 - answer question at index"
  echo "Enter/a - answer question at index (multi-char)"
  echo "d - delete answer by index"
  echo "e - edit existing answers"
  echo "h/? - answer mode help"
  echo "x/Q/Enter - exit answer mode"
}

#utils -- auxiliary functions used for main and mode functions

choose_mode_func() {
  if [[ "$1" == '?' || "$1" == 'h' ]]; then
    echo main_help
  elif [[ "$1" == 'q' ]]; then
    echo question_mode
  elif [[ "$1" == 't' ]]; then
    echo term_mode
  elif [[ "$1" == 'w' ]]; then
    echo answer_mode
  elif [[ "$1" == 'x' || "$1" == 'Q' ]]; then
    echo break
  elif [[ "$1" == 'y' ]]; then
    echo library_mode
  else
    echo 'echo "mode $mode not recognized"'
  fi
}

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
  read -n1 -p "Which library do you want to remove? " lib_choice
  echo
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

get_library_to_edit() {
  list_libraries >&2
  echo -n "Which library do you want to edit the name of? " >&2
  read -n1 lib_choice
  echo >&2
  if [[ "$lib_choice" =~ [0-9] ]]; then
    echo "$lib_choice"
  elif [[ ! "$lib_choice" ]]; then
    echo "$library_index"
  else
    echo "Invalid library index" >&2
  fi
}

edit_library() {
  local library_to_edit="$1"
  if [[ "$library_to_edit" ]]; then
    echo "Changing $library_to_edit "
    read -p "to ..... " new_library_name
    if [[ $new_library_name ]]; then
      read -n1 -p "Are you sure you want to change library $library_to_edit to $new_library_name? " confirmation
      echo
      if [[ $confirmation == "y" ]]; then
        mv Libraries/$library_to_edit Libraries/$new_library_name && echo "successfully moved library $library_to_edit to $new_library_name"
        if [[ $library == $library_to_edit ]]; then
          library=$new_library_name
        fi
      fi
    else
      echo "Ok then."
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
  local term_to_remove=
  read -n1 -p "Which term do you want to remove? " t_choice
  echo
  case "$t_choice" in
    [0-9])
      term_to_remove="$(get_term_by_index "$t_choice")"
      ;;
    a)
      read -p "Enter term to remove: " term_name
      term_to_remove="$(get_term_to_remove_by_name $term_name)"
      ;;
  esac
  if [[ "$term_to_remove" ]]; then
    read -n1 -p "Are you sure you want to remove $term_to_remove term? " confirmation
    echo
    if [[ $confirmation == "y" ]]; then
      rm -r Libraries/$library/$term_to_remove && echo "Term removed successfully"
      if [[ $term == $term_to_remove ]]; then
        term=-
      fi
    else
      echo "Ok. Term $term_to_remove is here to stay."
    fi
  fi
}

get_term_to_edit() {
  list_terms >&2
  echo -n "Which term do you want to edit the name of? " >&2
  read -n1 term_choice
  echo >&2
  if [[ "$term_choice" =~ [0-9] ]]; then
    echo "$term_choice"
  elif [[ ! "$term_choice" ]]; then
    echo "$term_index"
  else
    echo "Invalid term index" >&2
  fi
}

edit_term() {
  local term_to_edit="$1"
  if [[ "$term_to_edit" && "$library" ]]; then
    echo "Changing $term_to_edit "
    read -p "to ..... " new_term_name
    if [[ $new_term_name ]]; then
      read -n1 -p "Are you sure you want to change term $term_to_edit to $new_term_name? " confirmation
      echo
      if [[ $confirmation == "y" ]]; then
        mv Libraries/$library/$term_to_edit Libraries/$library/$new_term_name && echo "successfully moved term $term_to_edit to $new_term_name"
        if [[ $term == $term_to_edit ]]; then
          term=$new_term_name
        fi
      fi
    else
      echo "Ok then."
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
    a)
      read -p "Enter term to remove here: " term_to_remove
      echo
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
      echo "$question" >>Libraries/$library/$term/answers && echo "question was added to $term questions"
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
      echo "Question was $question_length words long. Please make sure questions are <= 8 words long. Question was not added."
    fi
  fi
}

list_questions() {
  local i=0
  while read line; do
    question="$(echo "$line" | sed 's/\(.*\?\).*/\1/')"
    if [[ $i == $question_index ]]; then
      echo "$i - $question *"
    else
      echo "$i - $question"
    fi
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
      read -n1 -p "Are you sure you want to remove the question \"$question_to_remove\" (Note this will also remove all of its answers!) " confirmation
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

remove_all_questions() {
  if [[ "$library" && "$term" ]]; then
    read -n1 -p "Are you sure you want to remove all answers from $term? (This eliminates answers as well and cannot be undone!) " confirmation
    echo
    if [[ $confirmation == y ]]; then
      echo -n "" >Libraries/$library/$term/answers
      question_index=0
    fi
  else
    echo "Library and/or term not defined"
  fi
}

get_question_to_edit() {
  list_questions >&2
  echo -n "Which question do you want to edit the name of? " >&2
  read -n1 question_choice
  echo >&2
  if [[ "$question_choice" =~ [0-9] ]]; then
    echo "$question_choice"
  elif [[ ! "$question_choice" ]]; then
    echo "$question_index"
  else
    echo "Invalid question index" >&2
  fi
}

edit_question() {
  local question_to_edit="$1"
  local temp_question_index="$2"
  if [[ "$question_to_edit" && "$term" && "$library" ]]; then
    echo "Changing $question_to_edit "
    read -p "to ..... " new_question
    if [[ $new_question ]]; then
      local new_question_length="$(echo "$new_question" | wc -w | sed 's/ *//')"
      if [[ "$new_question_length" -le 8 ]]; then
        read -n1 -p "Are you sure you want to change question \"$question_to_edit\" to \"$new_question\"? " confirmation
        echo
        if [[ $confirmation == "y" ]]; then
          if [[ ! $new_question =~ \?$ ]]; then
            new_question+="?"
          fi
          local question_position="$((temp_question_index + 1))"
          sed -i '' "${question_position}s/.*\?\(.*\)/$new_question\1/" Libraries/$library/$term/answers
          echo "successfully moved question \"$question_to_edit\" to \"$new_question\""
        fi
      else
        echo "Question was $new_question_length words long. Please make sure questions are <= 8 words long. Question was not changed."
      fi
    else
      echo "Ok then."
    fi
  fi
}

get_question_by_index() {
  question_index="$1"
  question_position="$(( question_index + 1 ))"
  sed -n "${question_position}p" Libraries/$library/$term/answers | sed 's/\(.*\?\).*/\1/'
}

get_answer_by_index() {
  local answer_index="$1"
  local answer_position="$((answer_index + 1))"
  local question_position="$((question_index + 1))"
  local current_question="$(sed -n "${question_position}p" Libraries/$library/$term/answers)"
  local question_with_newlines="$(echo $current_question | sed -r 's/\.|\? /\n/g')"
  i=0
  while read answer; do
    if (( i > 0 )); then
      if (( answer_position == i )); then
        echo "$answer"
        break
      fi
    fi
    (( i++ ))
  done <<< $question_with_newlines
}

answer_question_at_index() {
  question_index="$1"
  local question_position="$(( question_index + 1 ))"
  local question="$(sed -n "${question_position}p" Libraries/$library/$term/answers)"
  if [[ "$question" ]]; then
    read -p "$question " answer
    if [[ "$answer" ]]; then
      local answer_length="$(echo "$answer" | wc -w | sed 's/ *//')"
      if (( "$answer_length" > 8 )); then
        echo "Answer was $answer_length words long. Please make sure answers are <= 8 words long (note that I may add up to 8 answers per question). Answer was not added." && return 1
      else
        answer="$(echo ${answer^})"
        sed -i '' "${question_position}s/$/ $answer./" Libraries/$library/$term/answers && echo "Answer successfully added"
        previous_answers="$(list_answers_for_question_at_index "$question_index")"
        previous_answer_length="$(echo "$previous_answers" | wc -l | sed 's/ *//')"
        if (( previous_answer_length > 9 )); then #since answer is included, we need to check if it's greater than 9
          list_answers_for_question_at_index "$question_index"
          read -n1 -p "There can't be more than 8 answers for the same question. Please choose the index of the answer you want to get rid of: " answer_index
          echo
          remove_answer_by_indices "$question_index" "$answer_index"
        fi
      fi
    else
      echo "Empty answer was not added" && return 1
    fi
  fi
}

list_all_answers() {
  local i=0
  echo "Showing all answers:"
  while read line; do
    question="$(sed 's/\(.*\?\).*/\1/' <<<"$line")"
    if [[ $i == $question_index ]]; then
      echo "$i - $question *"
    else 
      echo "$i - $question"
    fi
    local j=-1
    while read inner_line; do
      if (( j > -1 )); then
        echo "  $j - $inner_line"
      fi
      (( j++ ))
    done < <(sed -r 's/([!.?]) ([A-Z]|[0-9])/\1\n\2/g' <<<"$line")
    (( i++ ))
  done < <(cat Libraries/$library/$term/answers)
  if [[ $i == 0 ]]; then
    echo "No answers exist yet for term $term"
  fi
}

remove_answer() {
  answer_count="$(list_answers_for_question_at_index "$question_index" | wc -l | sed 's/ *//')"
  if [[ "$question_index" && $answer_count -gt 1 ]]; then
    list_answers_for_question_at_index "$question_index"
    read -n1 -p "Which answer do you want to remove from said question? (* removes all answers) " a_index
    echo
    if [[ $question_index =~ [0-9] ]]; then
      if [[ $a_index == "*" ]]; then
        remove_all_answers_at_question_index "$question_index"
      else
        remove_answer_by_indices "$question_index" "$a_index"
      fi
    else
      echo "Invalid q index"
    fi
  else
    echo "No answers exist yet for question at index $question_index"
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
    else
      echo "Answer index was invalid. No answer was removed"
    fi
  fi
}

get_answer_to_edit() {
  list_answers_for_question_at_index "$question_index" >&2
  echo -n "Which answer do you want to edit the name of? " >&2
  read -n1 answer_choice
  echo >&2
  if [[ "$answer_choice" =~ [0-9] ]]; then
    echo "$answer_choice"
  elif [[ ! "$answer_choice" ]]; then
    echo 0
  else
    echo "Invalid answer index" >&2
  fi
}

edit_answer() {
  local answer_to_edit="$1"
  if [[ $(grep "$answer_to_edit" Libraries/$library/$term/answers) != "" ]]; then
    echo "Changing $answer_to_edit "
    read -p "to ..... " new_answer
    if [[ $new_answer ]]; then
      local new_answer_length="$(echo "$new_answer" | wc -w | sed 's/ *//')"
      if [[ "$new_answer_length" -le 8 ]]; then
        read -n1 -p "Are you sure you want to change answer \"$answer_to_edit\" to \"$new_answer\"? " confirmation
        echo
        if [[ $confirmation == "y" ]]; then
          question_position="$((question_index + 1))"
          echo "question position = $question_position" #
          sed -i '' "${question_position}s/\(.*\)$answer_to_edit\(.*\)/\1${new_answer^}\2/" Libraries/$library/$term/answers 
          echo "successfully moved answer \"$answer_to_edit\" to \"$new_answer\""
        fi
      else
        echo "Answer was $new_answer_length words long. Please make sure answers are <= 8 words long. Answer was not changed."
      fi
    else
      echo "Ok then."
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

safeguard_question_index() {
  if [[ "$1" ]]; then
    question_index="$1"
  fi
  answers_file_length="$(cat Libraries/$library/$term/answers | wc -l | sed 's/ *//')"
  max_question_index="$(( answers_file_length - 1 ))"
  if (( question_index > max_question_index )); then
    if (( max_question_index >= 0 )); then
      question_index=$max_question_index
    else
      question_index=0
    fi
  fi
}

get_question_count() {
  local count=0
  for question in Libraries/$library/$term/*; do
    count="$(( count + "$(cat "$question" | wc -l | sed 's/ *//')" ))"
  done
  echo "$count"
}

get_answer_count() {
  local question_and_answer_count= \
        answer_count= \

  local question_count="$(get_question_count)"
  if [[ -s Libraries/$library/$term/answers ]]; then
    question_and_answer_count="$(list_all_answers | wc -l | sed 's/ *//')"
    (( question_and_answer_count-- ))
  else
    question_and_answer_count=0
  fi
  answer_count="$(( question_and_answer_count - question_count ))"
  echo "$answer_count"
}

echo "QDD was successfully sourced"
