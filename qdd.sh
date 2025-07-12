#!/usr/local/bin/bash

source ~/p/bash-debugger

if [[ "$last_tub" ]]; then
  if [[ "$last_tub" == "$(pwd)" ]]; then
    library="${library:-"$(ls Libraries | head -1)"}"
    term="$(ls Libraries/$library | head -1)"
  else
    library_index=0
    term_index=0
    library=$(get_library_by_index 0)
    term=$(get_term_by_index 0)
    question_index=0
  fi
fi
last_tub="$(pwd)"

YELLOW="\e[93m"
RED="\e[91m"
GREEN="\e[92m"
CYAN="\e[96m"
PURPLE="\e[38;5;141m"
BLUE="\e[38;5;26m"
BLACK_FG_RED_BG="\e[30;101m"
MAGENTA="\e[35m"
ORANGE="\e[38;5;214m"
NC="\e[0m"

main() {
  clear
  while true; do
    echo -en "QDD ${RED}${library}${NC}:${GREEN}${term} ${NC}(main) $ "
    read -n1 mode
    echo
    if [[ $mode == '' ]]; then
      main
    else
      mode_func="$(choose_mode_func "$mode")"
      eval "$mode_func"
    fi
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
    echo -ne "${MAGENTA}QDD ${RED}$library:${GREEN}$term ${YELLOW}[${MAGENTA}$question_index${YELLOW}] ${MAGENTA}(question) ${NC}$ "
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
      c)
        read -n1 -p "Which question index would you like to copy to clipboard? " q_index
        echo
        if [[ ! "$q_index" =~ [0-9] ]]; then
          q_index=$question_index
          echo "used default question index $question_index"
        fi
        copy_question "$(get_question_by_index $q_index)"
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
      g)
        read -n1 -p "Which question index would you like to google and copy to clipboard? " q_index
        echo
        if [[ ! "$q_index" =~ [0-9] ]]; then
          local q_index=$question_index
          echo "used default question index $question_index"
        fi
        question_to_google="$(get_question_by_index $q_index)"
        copy_question "$question_to_google"
        google_keyword $question_to_google
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
  echo -ne "${GREEN}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${GREEN}$term_index${YELLOW}] ${GREEN}(term) ${NC}$ "
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
    g)
      google_documentation_for_current_term
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
  echo -ne "${ORANGE}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${ORANGE}$question_index${YELLOW}]${ORANGE} (answer) ${NC}$ "
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

rank_mode() {
  echo -ne "${CYAN}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${CYAN}$question_index${YELLOW}] ${CYAN}(rank) ${NC}$ "
  read -n1 command
  echo
  case "$command" in 
    q)
      list_questions
      read -n1 -p "Enter the index of the question you want to rank: " q_index
      echo
      if [[ "$q_index" ]]; then
        rank_question "$q_index"
      else
        rank_question "$question_index"
      fi
      ;;
    t)
      list_terms
      read -n1 -p "Enter the index of the term you want to rank: " t_index
      echo
      if [[ "$t_index" ]]; then
        rank_term "$t_index"
      else
        rank_term "$term_index"
      fi
      ;;
    y)
      list_libraries
      read -n1 -p "Enter the index of the library you want to rank: " lib_index
      echo
      if [[ "$lib_index" ]]; then
        if [[ "$lib_index" == '*' ]]; then
          rank_tub
        else
          rank_library "$lib_index"
        fi
      else
        rank_library "$library_index"
      fi
      ;;
    *)
      echo "command not recognized"
      ;;
  esac
}

library_mode() {
  library_index="$(get_library_index)"
  list_libraries
  echo -ne "${RED}QDD $library${NC}:${GREEN}$term ${YELLOW}[${RED}$library_index${YELLOW}]${RED} (library) ${NC}$ "
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
    h|\?)
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

edit_mode() {
  echo -ne "${BLUE}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${BLUE}$term_index${YELLOW}] ${BLUE}(edit) ${NC}$ "
  read -n1 command
  echo
  case "$command" in
    h|\?)
      edit_help
      ;;
    q|w)
      #this needs to be here because default breaks from function
      ;;
    t)
      list_terms
      read -n1 -p "Which term would you like to choose? " user_term_index
      echo
      if [[ $user_term_index ]]; then
        set_term_by_index $user_term_index
      fi
      ;;
    y)
      list_libraries
      read -n1 -p "Which library would you like to choose? " user_library_index
      echo
      if [[ $user_library_index ]]; then
        set_library_by_index $user_library_index
      fi
      list_terms
      read -n1 -p "Which term would you like to choose? " user_term_index
      echo
      if [[ $user_term_index ]]; then
        set_term_by_index $user_term_index
      fi
      echo
      ;;
    x|Q|'')
      return 0
      ;;
    *)
      echo "command not recognized"
      return 0
      ;;
  esac
  if [[ $library ]] && [[ $term ]] && [[ "ty" =~ $command ]] || [[ "qw" =~ $command ]]; then
    vim "Libraries/$library/$term/answers"
  else
    echo "Library or term for edit mode was not successfully selected"
  fi
}

google_mode() {
  echo -ne "${PURPLE}QDD ${RED}$library${NC}:${GREEN}$term ${YELLOW}[${PURPLE}$term_index${YELLOW}] ${PURPLE}(google) ${NC}$ "
  read -n1 command
  echo
  case "$command" in
    h|\?)
      google_help
      ;;
    q)
      list_questions
      safeguard_question_index
      read -n1 -p "Choose a question by index (leave blank for current question): " q_index
      echo
      if [[ ! $q_index =~ [0-7] ]] && [[ "$q_index" ]]; then
        return 0
      elif [[ ! $q_index =~ [0-7] ]]; then
        q_index=$question_index
      fi
      q=$(get_question_by_index $q_index)
      if [[ $q_index =~ [0-7] ]]; then
        google_search $q
      else
        echo "Sorry, no valid question was found at index $q_index"
      fi
      ;;
    t)
      wikipedia_search $term
      ;;
    y)
      wikipedia_search $library
      ;;
    w)
      list_answers_for_question_at_index $question_index
      read -n1 -s -p "Enter the index of the answer you want" answer_index
      echo
      if [[ $answer_index =~ [0-7] ]]; then
        local answer_position=$((answer_index+2))
        local answer_to_google=$(list_answers_for_question_at_index | sed -n "${answer_position}p" | sed 's/.*- \(.*\)\./\1/')
        if [[ $answer_to_google ]]; then
          google_search "$answer_to_google"
          answer_to_google=
        else
          echo "invalid answer index"
        fi
      else
        echo "invalid answer index"
      fi
      ;;
    x|Q|'')
      return 0
      ;;
    *)
      echo "command not recognized"
      return 0
      ;;
  esac
}

wikipedia_search() {
  open "https://en.wikipedia.org/wiki/$1"
  echo "Searched for $1 on wikipedia"
  sleep 0.5
}

google_search() {
  search=""
  for word in $@ ; do
    search="$search%20$word"
  done
  open "http://www.google.com/search?q=$search"
  echo "$search" | pbcopy
  echo "Searched for $@ and copied it to clipboard"
}

alias qdd='source qdd.sh'
alias qvv='vim /Users/jgolden1/bash/apps/question_driven_development/qdd.sh'

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

edit_help() {
  echo "Insert Mode Help:"
  echo "y - edit answers file for library at index, then term at index"
  echo "t - edit answers file for term at index"
  echo "q/w - edit answers file of current term"
  echo "h/? - edit mode help"
  echo "x/Q/Enter - exit edit mode"
}

google_help() {
  echo "Google Mode Help:"
  echo "y - look up library on wikipedia"
  echo "t - look up term on wikipedia"
  echo "q - google question"
  echo "w - google answer"
  echo "h/? - google mode help"
  echo "x/Q/Enter - exit google mode"
}

#utils -- auxiliary functions used for main and mode functions

choose_mode_func() {
  if [[ "$1" == '?' || "$1" == 'h' ]]; then
    echo main_help
  elif [[ "$1" == 'q' ]]; then
    echo question_mode
  elif [[ "$1" == 'w' ]]; then
    echo answer_mode
  elif [[ "$1" == 'e' ]]; then
    echo edit_mode
  elif [[ "$1" == 'r' ]]; then
    echo rank_mode
  elif [[ "$1" == 't' ]]; then
    echo term_mode
  elif [[ "$1" == 'x' || "$1" == 'Q' ]]; then
    echo break
  elif [[ "$1" == 'y' ]]; then
    echo library_mode
  elif [[ "$1" == 'u' ]]; then
    echo google_mode
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
    ensure_term_length_does_not_exceed_8
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
  ensure_term_length_does_not_exceed_8
}

ensure_term_length_does_not_exceed_8() {
  local terms_length="$(ls Libraries/$library | wc -l | sed 's/ *//')"
  if (( terms_length > 8 )); then
    terms_exceed_8=t
    while [[ $terms_exceed_8 == t ]]; do
      list_terms
      remove_term && terms_exceed_8=f
    done
  fi
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
    *)
      echo "Term not recognized"
      return 1
      ;;
  esac
  if [[ "$term_to_remove" ]]; then
    read -n1 -p "Are you sure you want to remove $term_to_remove term (note this will delete all its questions and answers as well)? " confirmation
    echo
    if [[ $confirmation == "y" ]]; then
      rm -r Libraries/$library/$term_to_remove && echo "Term removed successfully"
      if [[ $term == $term_to_remove ]]; then
        term=$(get_term_by_index "$(( --term_index ))")
        if [[ ! "$term" ]]; then
          term=$(get_term_by_index 0)
        fi
      fi
    else
      echo "Ok. Term $term_to_remove is here to stay."
      return 1
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
      question="$(echo ${question^})"
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
      question_index="$answers_length"
    else
      echo "Question was $question_length words long. Please make sure questions are <= 8 words long. Question was not added."
    fi
  fi
}

copy_question() {
  echo "$1" | pbcopy
  echo "question \"$1\" was successfully copied to the clipboard"
}

google_keyword() {
  local search=
  for word in $@ ; do
    search="$search%20$word"
  done
  open "http://www.google.com/search?q=$search"
  echo "googled \"$@\""
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
    read -n1 -p "Are you sure you want to remove all questions from $term? (This eliminates answers as well and cannot be undone!) " confirmation
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
  echo -n "Which question do you want to edit? " >&2
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
    new_question="$(echo ${new_question^})"
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
  local q_index="$1"
  question_position="$(( q_index + 1 ))"
  sed -n "${question_position}p" Libraries/$library/$term/answers | sed 's/\(.*\?\).*/\1/'
}

get_answer_by_index() {
  local answer_index="$1"
  local answer_position="$((answer_index + 1))"
  local question_position="$((question_index + 1))"
  local current_question="$(sed -n "${question_position}p" Libraries/$library/$term/answers)"
  local question_with_newlines="$(echo $current_question | sed 's/[.?] /\n/g')"
  i=0
  while read answer; do
    if (( i > 0 )); then
      if (( answer_position == i )); then
        if [[ "$answer" =~ \.$ ]]; then
          echo "${answer%?}"
        else
          echo "$answer"
        fi
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
  done < <(sed 's/\([\!\.\?]\) \([A-Z0-9]\)/\1\n\2/g' <<<"$line")
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
    done < <(sed 's/\([\!\.\?]\) \([A-Z0-9]\)/\1\n\2/g' <<<"$line")
    if [[ "$answer_to_remove" ]]; then
      sed -i '' "s/ $answer_to_remove//" Libraries/$library/$term/answers && echo "Answer \"$answer_to_remove\" was removed successfully"
    else
      echo "Answer index was invalid. No answer was removed"
    fi
  fi
}

get_answer_to_edit() {
  list_answers_for_question_at_index "$question_index" >&2
  echo -n "Which answer do you want to edit? " >&2
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

rank_question() {
  local number_of_answers="$(get_number_of_answers_at_question_index "$1")"
  local color="${NC}"
  local answer_status=
  local question="$(get_question_by_index "$1")"
  if [[ "$question" =~ '?' ]]; then
    case "$number_of_answers" in 
      0)
        answer_status="empty"
        color="$RED"
        ;;
      [1-2]) #low progress
        answer_status="low progress"
        color="$ORANGE"
        ;;
      [3-5]) #medium progress
        answer_status="medium progress"
        color="$YELLOW"
        ;;
      [6-7]) #near complete
        answer_status="near complete"
        color="$GREEN"
        ;;
      8) #complete
        answer_status="question complete"
        color="$CYAN"
        ;;
    esac
  else
    answer_status="non-existing question"
    color="$BLACK_FG_RED_BG"
  fi
  echo -e "${color}$1: ${question} - $number_of_answers answers ($answer_status)${NC}"
}

get_number_of_answers_at_question_index() {
  local lines_in_current_answers_file=$(list_answers_for_question_at_index "$1" | wc -l | sed 's/ *//')
  echo "$(( lines_in_current_answers_file - 1 ))"
}

rank_term() {
  local term_status=
  local color=
  og_term="$term"
  term=$(get_term_by_index $1)
  total_questions_answered=0
  if [[ "$term" ]]; then
  for n in {0..7}; do
    question_rank_description=$(rank_question "$n")
    echo "$question_rank_description"
    local new_questions_answered=$(get_number_of_answers_at_question_index "$n")
    total_questions_answered=$(( total_questions_answered + new_questions_answered ))
  done
    case "$total_questions_answered" in 
      0)
        term_status="empty"
        color="$RED"
        ;;
      [1-9]|1[0-9]|20)
        term_status="low progress"
        color="$ORANGE"
        ;;
      2[1-9]|3[0-9]|4[0-5])
        term_status="medium progress"
        color="$YELLOW"
        ;;
      4[6-9]|5[0-9]|6[0-3])
        term_status="near complete"
        color="$GREEN"
        ;;
      64)
        term_status="term complete"
        color="$CYAN"
        ;;
    esac
  else
    term_status="non-existing term"
    color="$BLACK_FG_RED_BG"
  fi
  echo -e "  ${color}$1: ${term} - $total_questions_answered answers ($term_status)${NC}"
  term="$og_term"
}

rank_library() {
  local lib_status=
  local color=
  og_lib="$library"
  library=$(get_library_by_index $1)
  local total_questions_answered=0
  local number_of_terms=$(ls Libraries/$library | wc -l | sed 's/ *//')
  for n in $(seq 0 "$number_of_terms"); do
    term_rank_description=$(rank_term "$n")
    echo "$term_rank_description" | grep -v "non-existing" | grep "  "
    local new_questions_answered=$(echo "$term_rank_description" | tail -1 | sed -r 's/.* ([0-9]*) answers.*/\1/')
    total_questions_answered=$(( total_questions_answered + new_questions_answered ))
  done
  if [[ "$library" ]]; then
    if (( total_questions_answered == 0 )); then
      library_status="empty"
      color="$RED"
    elif (( total_questions_answered < 161 )); then
      library_status="low progress"
      color="$ORANGE"
    elif (( total_questions_answered < 360 )); then
      library_status="medium progress"
      color="$YELLOW"
    elif (( total_questions_answered < 512 )); then
      library_status="near complete"
      color="$GREEN"
    elif (( total_questions_answered == 512 )); then
      library_status="library complete"
      color="$CYAN"
    fi
  else
    library_status="non-existing library"
    color="$BLACK_FG_RED_BG"
  fi
  echo -e "    ${color}$1: ${library} - $total_questions_answered answers ($library_status)${NC}"
  library="$og_lib"
}

rank_tub() {
  local i=0
  for lib in Libraries/*; do
    rank_library "$i" | grep "    "
    (( i++ ))
  done
}

google_documentation_for_current_term() {
  read -n1 -p "Enter the index of the term I want to google documentation for: " t_index
  echo
  term_to_google="$(get_term_by_index $t_index)"
  if [[ "$term_to_google" ]]; then
    google_message="official $term_to_google documentation"
    google_keyword "$google_message"
    echo "Keep in mind, the web page I want from this will often not be the first one. Look for documentation that is..."
    echo "1) Official"
    echo "2) Made by experts"
    echo "3) Filled with first-hand knowledge (not watered down)"
  else
    echo "Invalid term index"
  fi
}

main
