#!/bin/bash
#All functions and aliases relevant to question_driven_development project

#set -u

exec 3<&0
chat_flippity_path="/Users/jgolden1/bash/apps/chat_flippity/chat_flippity.sh"
source $chat_flippity_path
current_term="${current_term:-}"
match=

BLACK_FG=$'\033[38:5:0m'
RED_FG=$'\[\e[30;31m\]'
GREEN_FG=$'\[\e[30;32m\]'
MAGENTA_FG=$'\[\e[30;35m\]'
GOLD_BG=$'\033[48:5:3m'
GREY_BG=$'\033[48:5:7m'
RED_BG=$'\033[30;101m'
GREEN_BG=$'\033[30;102m'
BLUE_BG=$'\033[30;104m'
NC=$'\e[0m'
NL=$'\n'

questions_from_input() {
  if [[ -n "$current_term" ]]; then
    line_number=1
    input_file=$(cat)
    input_length="$(echo "$input_file" | sentencify | wc -l | sed 's/ //g')"
    while IFS= read -r line; do
      if [[ $line == "" ]] || [[ $line == " " ]]; then
        continue
      else
        while true ; do
          [[ $prev_line ]] && line="${prev_line}${line}" && prev_line=
          [[ -n $1 ]] && line_start="$1" || line_start=1
          [[ $line_number -lt $line_start ]] && break
          percent=$((line_number * 100 / input_length))
          printf "\033c"
          if [[ -n $match ]]; then 
            if [[ $(echo $line | grep "$match") != "" ]]; then
              echo "Match \"$match\" found!" 
              echo "$line"
              unset match
            else
              break
            fi
          else
            echo "$line"
          fi
          echo "${BLACK_FG}${GREY_BG}line $line_number of $input_length ${GOLD_BG} ${percent}% ${RED_BG} "$(pwd | sed 's/.*\///g')" ${GREEN_BG} ${current_term} ${BLUE_BG} ❓ ${NC}"
          read -n1 -r -s input <&3
          case $input in
            a)
              read -p "Enter question here: " question <&3
              add_question "$question"
              sleep 1
              ;;
            b)
              if [[ $line_number -gt 1 ]]; then
                echo "$input_file" | questions_from_input $(( line_number - 1 ))
                break 2
              else
                echo "Cannot go back."
                sleep 0.5
              fi
              ;;
            c)
              chat_flippity <&3 #see flippity_prompt for overridden method
              sleep 0.75
              ;;
            e)
              read -p "bash $ " commands <&3
              if [[ $commands ]]; then
                eval "$commands"
                read -s -n1 -p "Type any key to continue" any_key <&3
              else
                echo "no command was entered"
                sleep 0.5
              fi
              ;;
            f)
              flashcards
              sleep 1
              ;;
            g)
              read -p "What do you want to look up?: " search <&3
              if [[ -n $search ]]; then
                echo "$search" | pbcopy
                google "$search"
              else
                echo "invalid search request"
                sleep 0.5
              fi
              ;;
            G)
              questions=()
              index=0
              while read question; do
                questions+=("$question");
                echo "$index - $question"
                (( index++ ))
              done <"Terms/$current_term/questions"
              read -p "please choose which of the above questions to google and copy to clipboard: " q_ind <&3
              if [[ -n $q_ind ]] && [[ ! "$q_ind" =~ [a-zA-Z] ]] && [[ -n ${questions[$q_ind]} ]]; then
                search="${questions[$q_ind]}"
                if [[ -n $search ]]; then
                  echo "$search" | pbcopy
                  google "$search"
                else
                  echo "invalid search request"
                  sleep 0.5
                fi
              else
                echo "Invalid question index."
                sleep 0.5
              fi
              ;;
            h)
              help_log="COMMAND HELP${NL}"
              help_log+="a = [a]dd a question to current term's questions file${NL}"
              help_log+="b = go [b]ack 1 input line${NL}" 
              help_log+="c = use [c]hat flippity program to generate a question for chatGPT (note - this depends on chat_flippity.sh file)${NL}" 
              help_log+="e = [e]valuate string as though typing on command line${NL}" 
              help_log+="f = [f]lashcards (for becoming more familiar with recently answered questions)${NL}" 
              help_log+="g = [g]oogle user input${NL}" 
              help_log+="G = [G]oogle one of current term's questions${NL}"
              help_log+="h = display qfi command [h]elp${NL}"
              help_log+="j = [j]ump to input line by number${NL}" 
              help_log+="k = open lin[k] by index from link file in new google tab${NL}" 
              help_log+="l = open [l]ist menu for questions, answers, statements, terms, libraries, sections, etc${NL}" 
              help_log+="m = go to book[m]ark${NL}" 
              help_log+="n = [n]ext input line${NL}" 
              help_log+="N = combi[N]e current line with next line and show as one line${NL}"
              help_log+="o = view [o]riginal line (no combined inputs)${NL}"
              help_log+="p = a[p]pend current line to research.txt${NL}" 
              help_log+="q = [q]uit qfi${NL}" 
              help_log+="s = [s]ection hopper${NL}" 
              help_log+="t = list and change current [t]erm${NL}" 
              help_log+="v = [v]im into questions, answers, research, or links${NL}"
              help_log+="w = ans[w]er one of the current term's questions${NL}"
              help_log+="W = ans[W]er one of the current term's unanswered questions${NL}" 
              help_log+="y = list all libraries and change current librar[y]${NL}" 
              help_log+="z = append current term to selected term [z]${NL}"
              help_log+="0 = go to beginning of input lines (works like vim's [0])${NL}"
              help_log+="# = hotkey for l[#], which lists basic question, answer, statement, and term stats${NL}" 
              help_log+="$ = go to end of input lines (works like vim's [$])${NL}" 
              help_log+="^ = google current input line and copy it to clipboard [^]${NL}" 
              help_log+="& = copy current input line to clipboard [&]${NL}" 
              help_log+="[ = google first unanswered question${NL}"
              help_log+="] = google last unanswered question${NL}"
              help_log+="{ = google first question (whether answered or unanswered)${NL}"
              help_log+="} = google last question(whether answered or unanswered)${NL}"
              help_log+=", = answer first unanswered question[.]${NL}"
              help_log+=". = answer last unanswered question [,]${NL}"
              help_log+="< = answer first question (whether answered or not) [<]${NL}"
              help_log+="> = answer last question (whether answered or not) [>]${NL}"
              help_log+="/ = search for a string in input lines (from current location, works like vim's [/])${NL}"
              help_log+="? = search for a string in statements (same as gz) [?]"
              echo "$help_log" | more -P "q to exit"
              ;;
            j)
              read -p "Jump to which line number? " user_line_start <&3
              if [[ $user_line_start -gt $input_length ]]; then
                echo "Sorry, there are only $input_length lines in total. Please jump to a smaller number."
                sleep 1
              elif [[ ! $user_line_start =~ [0-9] ]]; then
                echo "Please enter a valid line number."
                sleep 1
              else
                echo "$input_file" | questions_from_input "$user_line_start"
                break 2
              fi
              ;;
            k)
              list_of_links=()
              i=0
              while read link; do
                link_name=$(echo "$link" | sed 's/\(.*\): .*/\1/')
                relevant_link=$(echo "$link" | sed 's/.*: \(.*\)/\1/')
                list_of_links+=("$relevant_link")
                echo "$i - $link_name"
                (( i++ ))
              done < links
              read -p "Type the index of the link you want to open: " link_index <&3
              if [[ "$link_index" ]] && [[ $link_index -lt "$i" ]] && [[ $link_index -ge 0 ]]; then
                if [[ $(grep "${list_of_links[$link_index]}" links) != "" ]]; then 
                  echo "Going to link ${list_of_links[$link_index]}"
                  open "${list_of_links[$link_index]}"
                else
                  echo "Link name not found"
                  sleep 0.5
                fi
              else
                echo "Invalid link index"
                sleep 0.5
              fi
              ;;
            l)
              read -s -n1 -p "What would you like to list?"$'\n'"a/A - answers, l/L - answers, questions, and statements, q/Q - questions, r - relevant answers (to current line), s - sections, t - terms, u/U - unanswered, y - libraries, z/Z - statements, # - numbers. lowercase = current term; UPPERCASE = ALL terms in library."$'\n' list_op <&3
              case $list_op in 
              a)
                list answers
                ;;
              A)
                list answers all
                ;;
              l)
                list
                ;;
              L)
                list all
                ;;
              r)
                tput cup 2 0
                tput ed
                echo "$line ..." | get_statement_from_answer
                while read answer; do
                  if [[ "$answer" =~ "$line" ]]; then
                    echo -n "-"
                    echo "$answer" | sed "s/$line \(.*\)/\1/"
                  fi
                done < "Terms/$current_term/answers"
                ;;
              q)
                list questions
                ;;
              Q)
                list questions all
                ;;
              s)
                cat research.txt | sentencify | grep -nE "^[A-Z ]+$"
                ;;
              t)
                list_terms
                ;;
              u)
                list_unanswered_questions
                ;;
              U)
                list_unanswered_questions_all
                ;;
              y)
                list_libraries
                ;;
              z)
                list statements
                ;;
              Z)
                list statements all
                ;;
              \#)
                list_numbers
                ;;
              *)
                echo "Input not recognized. Please refer to the prompt for commands."
                sleep 1
                continue
                ;;
              esac
              echo ""
              press_any_key_to_escape <&3
              ;;
            m)
              match="BOOKMARK"
              break
              ;;
            n | "")
              break;
              ;;
            N)
              prev_line="$line${NL}"
              break;
              ;;
            o)
              prev_line=
              echo "$input_file" | questions_from_input "$line_number"
              break 2
              ;;
            p)
              if [[ $(grep "$line" research.txt) != "" ]]; then
                echo "❌ Line already exists in research.txt"
                sleep 0.5
              else
                echo "$line" >>research.txt
                echo "✅ Line added to research.txt"
                sleep 0.5
              fi
              ;;
            q)
              break 2
              ;;
            s)
              sections=()
              index=0
              while read section; do
                section_line=$(echo "$section" | sed 's/\(.*\):.*/\1/')
                section_display=$(echo "$section" | sed 's/.*\:\(.*\)/\1/')
                sections+=("$section_line")
                echo "$index - $section_display"
                (( index++ ))
              done < <(echo "$input_file" | sentencify | grep -nE "^[A-Z ]*$")
              read -p "Please choose which of the above sections you would like to jump to: " s_ind <&3
              if [[ $s_ind =~ [0-9] ]] && [[ $s_ind -lt "${#sections[@]}" ]]; then
                echo "$input_file" | questions_from_input "${sections[$s_ind]}"
                break 2
              else
                echo "Invalid section index."
                sleep 0.5
              fi
              ;;
            t)
              list_terms
              echo
              read -p "Change term $current_term to: " new_term <&3
              change_term "$new_term"
              sleep 0.75
              ;;
            v)
              echo "a = current term's answers"
              echo "l = links"
              echo "q = current term's questions"
              echo "r = research.txt"
              read -n1 -p "Which of the above would you like to vim into? " vim_choice <&3
              exec 4<&3
              case $vim_choice in
                a)
                  eval vim_answers_current_term <&4
                ;;
                l)
                  eval vi links <&4
                ;;
                q)
                  eval vim_questions_current_term <&4
                ;;
                r)
                  eval vi research.txt <&4
                ;;
              esac
              exec 4<&-
              ;;
            w|W)
              questions=()
              index=0
              [[ $input == "W" ]] && echo "UNANSWERED:"
              while read question; do
                if [[ "$input" == "W" ]]; then
                  grep -q "$question" "Terms/$current_term/answers" && continue
                fi
                questions+=("$question");
                echo "$index - $question"
                (( index++ ))
              done <"Terms/$current_term/questions"
              if [[ ${#questions} -gt 0 ]]; then
                echo
                read -p "Please choose which of the above questions you would like to answer: " q_ind <&3
                if [[ -n $q_ind ]] && [[ ! "$q_ind" =~ [a-zA-Z] ]] && [[ -n ${questions[$q_ind]} ]]; then
                  tput cup 2 0
                  tput ed
                  echo "${questions[$q_ind]}"
                  if [[ "$(get_statement_from_answer "${questions[$q_ind]} ")" != "" ]]; then
                    question_prompt="$(get_statement_from_answer "${questions[$q_ind]} ") "
                  else
                    question_prompt="WARNING: Statement not set up for current question. "
                  fi
                  read -p "$question_prompt" answer <&3
                  add_answer "${questions[$q_ind]}" "$answer" 
                  sleep 0.5
                else
                  echo "Invalid question index."
                  sleep 0.5
                fi
              else
                [[ $input == 'w' ]] && echo "No questions found for $current_term." || echo "No unanswered questions found for $current_term."
                sleep 1
              fi
              ;;
            y)
              list_libraries
              echo
              read -p "which library do you want to change to? " library <&3
              if [[ -d ../$library ]]; then
                change_library $library
                sleep 0.5
              else
                echo "Invalid library name."
                sleep 0.5
              fi
              ;;
            z)
              list_terms
              read -p "Which term would you like to append $current_term to?: " term_to_append <&3
              append_term "$term_to_append"
              sleep 0.75
              ;;
            Z)
              statements=$(statements_from_answers <&3)
              echo "${statements}${NL}"
              press_any_key_to_escape <&3
              ;;
            0)
              echo "$input_file" | questions_from_input
              break 2;
              ;;
            \#)
              list_numbers
              echo
              press_any_key_to_escape <&3
              ;;
            $)
              echo "$input_file" | questions_from_input "$input_length"
              break 2
              ;;
            ^)
              if [[ -n $line ]]; then
                search_line=$(echo "$line" | sed 's/UNANSWERED: //')
                echo $search_line | pbcopy
                google "$search_line"
              fi
              ;;
            \&)
              if [[ -n $line ]]; then
                line_to_copy=$(echo "$line" | sed 's/UNANSWERED: //')
                echo $line_to_copy | pbcopy
                echo "line copied to clipboard"
                sleep 0.5
              fi
              ;;
            \[)
              while read question; do
                if [[ $(grep "$question" "Terms/$current_term/answers") == "" ]]; then
                  first_unanswered_question=("$question");
                  break
                fi
              done <"Terms/$current_term/questions"
              if [[ "$first_unanswered_question" ]]; then
                echo "$first_unanswered_question" | pbcopy
                google "$first_unanswered_question"
                echo "copied and googled \"$first_unanswered_question\""
              else
                echo "No unanswered question exists, so nothing was searched or copied to clipboard"
              fi
              sleep 0.75
              ;;
            \])
              last_unanswered_question=""
              while read question; do
                if [[ $(grep "$question" "Terms/$current_term/answers") == "" ]]; then
                  last_unanswered_question=("$question");
                  break
                fi
              done < <(tail -r "Terms/$current_term/questions")
              if [[ "$last_unanswered_question" ]]; then
                echo "$last_unanswered_question" | pbcopy
                google "$last_unanswered_question"
                echo "copied and googled \"$last_unanswered_question\""
              else
                echo "No unanswered question exists, so nothing was searched or copied to clipboard"
              fi
              sleep 0.75
              ;;
            {)
              first_question=$(head -1 "Terms/$current_term/questions")
              if [[ "$first_question" ]]; then
                echo "$first_question" | pbcopy
                google "$first_question"
                echo "copied and googled \"$first_question\""
              else
                echo "No question exists, so nothing was searched or copied to clipboard"
              fi
              sleep 0.75
              ;;
            \})
              last_question=$(tail -1 "Terms/$current_term/questions")
              if [[ "$last_question" ]]; then
                echo "$last_question" | pbcopy
                google "$last_question"
                echo "copied and googled \"$last_question\""
              else
                echo "No question exists, so nothing was searched or copied to clipboard"
              fi
              sleep 0.75
              ;;
            ,)
              first_unanswered_question=""
              while read question; do
                if [[ $(grep "$question" "Terms/$current_term/answers") == "" ]]; then
                  first_unanswered_question=("$question");
                  break
                fi
              done <"Terms/$current_term/questions"
              if [[ -n "$first_unanswered_question" ]]; then 
                echo "$first_unanswered_question"
                if [[ "$(get_statement_from_answer "$first_unanswered_question")" != "" ]]; then
                  question_prompt="$(get_statement_from_answer "$first_unanswered_question ") "
                else
                  question_prompt="WARNING: Statement not set up for current question. "
                fi
                read -p "$question_prompt" answer <&3
                add_answer "$first_unanswered_question" "$answer" 
              else
                echo "No unanswered question exists"
              fi
              sleep 0.5
              ;;
            \.)
              last_unanswered_question=""
              while read question; do
                if [[ $(grep "$question" "Terms/$current_term/answers") == "" ]]; then
                  last_unanswered_question=("$question");
                  break
                fi
              done < <(tail -r "Terms/$current_term/questions")
              if [[ -n "$last_unanswered_question" ]]; then 
                echo "$last_unanswered_question"
                if [[ "$(get_statement_from_answer "$last_unanswered_question")" != "" ]]; then
                  question_prompt="$(get_statement_from_answer "$last_unanswered_question ") "
                else
                  question_prompt="WARNING: Statement not set up for current question. "
                fi
                read -p "$question_prompt" answer <&3
                add_answer "$last_unanswered_question" "$answer" 
              else
                echo "No unanswered question exists"
              fi
              sleep 0.5
              ;;
            \<)
              first_question=$(cat Terms/$current_term/questions | head -1)
              if [[ "$first_question" ]]; then 
                echo "$first_question"
                if [[ "$(get_statement_from_answer "$first_question")" != "" ]]; then
                  question_prompt="$(get_statement_from_answer "$first_question ") "
                else
                  question_prompt="WARNING: Statement not set up for current question. "
                fi
                read -p "$question_prompt" answer <&3
                add_answer "$first_question" "$answer" 
              else
                echo "No unanswered question exists"
              fi
              sleep 0.5
              ;;
            \>)
              last_question=$(cat Terms/$current_term/questions | tail -1)
              if [[ "$last_question" ]]; then 
                echo "$last_question"
                if [[ "$(get_statement_from_answer "$last_question")" != "" ]]; then
                  question_prompt="$(get_statement_from_answer "$last_question ") "
                else
                  question_prompt="WARNING: Statement not set up for current question. "
                fi
                read -p "$question_prompt" answer <&3
                add_answer "$last_question" "$answer" 
              else
                echo "No unanswered question exists"
              fi
              sleep 0.5
              ;;
            /)
              read -p "Enter search target: " target <&3
              if [[ -n "$target" ]]; then
                match="$target"
                break
              else
                echo "Invalid target"
                sleep 0.5
              fi
              ;;
            \?)
              read -p "gz " target <&3
              grep_statements_case_insensitive "$target"
              press_any_key_to_escape <&3
              ;;
            *)
              echo "Sorry, \"$input\" command not recognized."
              sleep 0.5
              ;;
          esac
        done
      fi
      line_number=$(($line_number + 1))
    done < <(echo "$input_file" | sentencify)
  else
    echo "You have not yet defined a current term. Please do so with change_term, then try again."
  fi
}

questions_from_nothing() {
  echo "nothing" | questions_from_input "$1"
}

questions_from_questions() {
  questions=""
  while read question; do
    grep -q "$question" "Terms/$current_term/answers" && questions+="$question " || questions+="UNANSWERED: $question "
  done < <(list questions | sed '1d')
  echo $questions | questions_from_input "$1"
}

questions_from_unanswered_questions() {
  list_unanswered_questions | sed '1d' | qfi "$1"
}

questions_from_research() {
  cat research.txt | questions_from_input "$1"
}

questions_from_statements() {
  list statements | sed '1d' | questions_from_input "$@"
}

statements_from_answers() {
  [[ -n "$1" ]] && term="$1" || term="$current_term"
  empty_file "Terms/$term/statements"
  while read line; do
    echo "$(get_statement_from_answer "$line")." >>"Terms/$term/statements"
  done <"Terms/$term/answers"
  number="$(cat "Terms/$term/statements" | cat | wc -l | sed 's/ //g')"
  echo "<-- $number statements about $term -->"
  cat "Terms/$term/statements"
}

case_sensitive=${case_sensitive:-true} #default

grep_statements() {
  if [[ "$1" ]]; then
    if [[ $case_sensitive == true ]]; then
      res=$(cat "Terms/$current_term/statements" | grep "$1")
    else
      res=$(cat "Terms/$current_term/statements" | grep -i "$1")
    fi
    line_count=$(echo "$res" | wc -l | sed 's/ //g')
    echo "$line_count lines found matching \"$1\""
    echo "$res"
  else
    echo "invalid search request"
  fi
}

grep_statements_case_sensitive() {
  case_sensitive=true
  grep_statements "$1"
}

grep_statements_case_insensitive() {
  case_sensitive=false
  grep_statements "$1"
}

statements_from_answers_all() {
  while read term; do
    statements_from_answers "$term"
  done < <(ls Terms)
}

capitalize_first_letter() {
  read line
  echo "$line" | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}'
}

list() {
  if [[ "$1" == "questions" || "$1" == "answers" || "$1" == "statements" ]]; then
    if [[ "$2" == "all" ]]; then
      last_term="$(ls Terms | tail -1)"
      for term in $(ls Terms); do
        echo "[ $term ]"
        number="$(cat "Terms/$term/$1" | cat | wc -l | sed 's/ //g')"
        echo "<-- $number $1 about $term -->"
        cat "Terms/$term/$1"
        if [[ $term != $last_term ]]; then
          echo
        fi
      done
    elif [[ -n $current_term ]]; then
      number="$(cat "Terms/$current_term/$1" | cat | wc -l | sed 's/ //g')"
      echo "<-- $number $1 about $current_term -->"
      cat "Terms/$current_term/$1"
    else
      echo "You have not yet defined a current term. Please do so with change_term, then try again."
    fi
  elif [[ -z "$1" ]] || [[ $1 == "all" ]]; then
    echo "{** Questions **}"
    list questions "$1"
    echo
    echo "{** Answers **}"
    list answers "$1"
    echo
    echo "{** Statements **}"
    list statements "$1"
  else
    echo "First parameter was incorrect. After list, please type \"questions\", \"answers\", or \"statements\". Calling list with no parameters lists questions, answers, and statements for current term. Calling list all lists questions, answers, and statements for ALL terms in current library."
  fi
}

flashcards() {
  i=1
  hide_q=false
  hide_a=true
  questions_length=$(cat "Terms/$current_term/questions" | wc -l | sed 's/ //g')
  while [[ $i -le $questions_length ]]; do
    printf "\033c"
    current_question=$(cat "Terms/$current_term/questions" | sed -n "${i}p")
    current_answers=$(cat "Terms/$current_term/answers" | grep "$current_question")
    echo "Flashcard ${i}/${questions_length}"
    if [[ $hide_q == false ]]; then
      echo "Q - $current_question"
    else
      echo "*hidden* (press w to reveal)"
    fi
    if [[ $hide_a == false ]]; then
      j=1
      while read answer; do
        echo "A${j} - $answer"
        (( j++ ))
      done < <(cat "Terms/$current_term/answers" | grep "$current_question" | sed 's/\(.*\?\) \(.*\)/\2/')
    else
      echo "*hidden* (press a to reveal)"
    fi
    read -n1 -s -p "a = hide/reveal answer; b = back to previous flashcard; j = jump to flashcard; n = next flashcard; q = quit; w = hide/reveal question: ${NL}" key <&3
    case $key in
      a)
        if [[ $hide_a == "true" ]]; then
          hide_a=false
        else
          hide_a=true
        fi
        ;;
      b)
        if [[ $i -gt 1 ]]; then
          (( i-- ))
        else
          echo "can't go any further back"
          sleep 0.5
        fi
        ;;
      j)
        read -p "Jump to flashcard #" fc_number <&3
        if [[ $fc_number -gt $questions_length ]]; then
          echo "flashcard number is too high, jumping to last flashcard"
          sleep 0.5
          i=$questions_length
        elif [[ $fc_number -lt 1 ]]; then
          echo "flashcard number is too low, jumping to first flashcard"
          sleep 0.5
          i=1
        else
          i=$fc_number
        fi
        ;;
      n)
        (( i++ ))
        ;;
      q)
        break 2
        ;;
      w)
        if [[ $hide_q == "true" ]]; then
          hide_q=false
        else
          hide_q=true
        fi
        ;;
      *)
        echo "key not recognized."
        ;;
    esac
  done
}

add_answer() { #$1 = question, $2 = answer
  if [[ -n $current_term ]]; then
    if [[ "$1" =~ "?" ]] && [[ "$2" != "" ]]; then
      grep -q "$1" "Terms/$current_term/questions" || add_question "$1"
      echo "$1 $2" >>"Terms/$current_term/answers" && echo "answer was added to $current_term answers" || echo "ERROR: question was not added to $current_term answers."
    else
      echo "question and/or answer was invalid"
    fi
  else
    echo "You have not yet defined a current term. Please do so with change_term, then try again."
  fi
}

vim_answers_current_term() {
  if [[ -n $current_term ]]; then
    vi "Terms/$current_term/answers"
  else
    echo "You have not yet defined a current term. Please do so with change_term, then try again."
  fi
}

add_question() {
  if [[ -n $current_term ]]; then
    if [[ $1 =~ "?" ]]; then
      echo -e "$1" >>"Terms/$current_term/questions" 
      number_of_questions="$(cat Terms/$current_term/questions | wc -l | sed 's/ //g')"
      echo "question was added to $current_term questions. $current_term now has $number_of_questions questions."
    else
      echo "Invalid question format."
    fi
  else
    echo "You have not yet defined a current term. Please do so with change_term, then try again."
  fi
}

list_numbers() { #lists the number of answered questions, unanswered questions, answers, and statements in the current term, as well as the number of terms in the current library
  number_of_questions=$(cat "Terms/$current_term/questions" | wc -l | sed 's/ //g')
  number_of_unanswered_questions=0
  while read question; do
    if [[ ! "$(grep "$question" "Terms/$current_term/answers")" ]]; then
      (( number_of_unanswered_questions++ ))
    fi
  done <"Terms/$current_term/questions"
  number_of_answers=$(cat "Terms/$current_term/answers" | wc -l | sed 's/ //g')
  number_of_statements=$(cat "Terms/$current_term/statements" | wc -l | sed 's/ //g')
  number_of_terms=$(ls -1 Terms | wc -l | sed 's/ //g')
  echo "questions ---------------> $number_of_questions"
  echo "unanswered questions ----> $number_of_unanswered_questions"
  echo "answers -----------------> $number_of_answers"
  echo "statements --------------> $number_of_statements"
  echo "terms -------------------> $number_of_terms"
}

list_unanswered_questions() {
  [[ -n "$1" ]] && term="$1" || term="$current_term"
  if [[ -n $term ]]; then
    unanswered_questions=""
    while read question; do
      if [[ "$(grep "$question" "Terms/$term/answers")"  == "" ]]; then
        unanswered_questions+="$question\n"
      fi
    done <"Terms/$term/questions"
    unanswered_questions="${unanswered_questions%'\n'}"
    if [[ -n $unanswered_questions ]]; then
      number_of_unanswered_questions="$(echo -e $unanswered_questions | wc -l | sed 's/^[[:space:]]*//')"
      echo -e "<-- $number_of_unanswered_questions unanswered questions about $term -->"
      echo -e "$unanswered_questions"
    else
      echo -e "<-- 0 unanswered questions about $term -->"
    fi
  else
    echo "You have not yet defined a current term. Please do so with change_term, then try again."
  fi
}

list_unanswered_questions_all() {
  while read term; do
    echo "[ $term unanswered questions ]"
    list_unanswered_questions "$term"
    echo
  done < <(ls Terms)
}

vim_questions_current_term() {
  if [[ -n $current_term ]]; then
    vi "Terms/$current_term/questions"
  else
    echo "You have not yet defined a current term. Please do so with change_term, then try again."
  fi
}

vim_statements_current_term() {
  if [[ -n $current_term ]]; then
    vi "Terms/$current_term/statements"
  else
    echo "You have not yet defined a current term. Please do so with change_term, then try again."
  fi
}

append_term() {
  if [[ "$1" ]] && [[ $(ls Terms | grep "$1") != "" ]]; then 
    cat Terms/$current_term/questions >>Terms/$1/questions
    cat Terms/$current_term/answers >>Terms/$1/answers
    cat Terms/$current_term/statements >>Terms/$1/statements
    echo "appended current term to \""$1"\" category"
  else
    echo "Invalid term"
  fi
}

change_term() { 
  if [[ -n "$1" ]]; then
    if [[ ! -d "Terms/$1" ]]; then
      mkdir "Terms/$1"
      touch "Terms/$1/answers" "Terms/$1/questions" "Terms/$1/statements"
      echo "Added directory $1 to Terms, with answers, questions, and statements files. View a list of all terms with list_terms or lt"
    fi
    current_term="$1"
    echo "changed current term to $current_term"
  else
    echo "term was invalid."
  fi
  update_qdd_prompt
}

empty_term() {
  if [[ "$1" ]]; then
    term_to_empty="$1"
  else
    term_to_empty="$current_term"
  fi
  if [[ -d "Terms/$term_to_empty" ]]; then
    read -p "Are you sure you want to empty term \"$current_term\"? " user_confirmation
    if [[ $user_confirmation =~ y|Y ]]; then
      empty_file Terms/$current_term/questions
      empty_file Terms/$current_term/answers
      empty_file Terms/$current_term/statements
      echo "Emptied term \"$current_term\""
    else
      echo "Ok, no emptying will take place"
    fi
  else
    echo "Invalid term"
  fi
}

list_terms() {
  number_of_terms="$(ls Terms | cat | wc -l | sed 's/.*\([0-9]+\).*/\1/' | sed 's/ //g')"
  echo "<-- $number_of_terms Terms -->"
  ls -1 Terms
}

move_term() {
  if [[ -n "$1" ]]; then
    mv "Terms/$current_term" "Terms/$1"
    touch "Terms/$1/answers" "Terms/$1/questions" "Terms/$1/statements"
    rm -rf "Terms/$current_term"
    current_term="$1"
    echo "Moved $current_term to $1."
  else
    echo "term was invalid."
  fi
  update_qdd_prompt
}

remove_term() {
  if [[ "$1" ]] && [[ -d "Terms/$1" ]]; then
    rm -r "Terms/$1/"
    echo "removed term $1"
    if [[ $current_term == "$1" ]]; then
      current_term="detached"
    fi
    update_qdd_prompt
  else
    echo "Term was not found, so no removal took place"
  fi
}

term_search() {
  if [[ "$1" ]]; then
    term=
    if [[ "$2" ]]; then
      term="$2"
    else
      term="$current_term"
    fi
    number_of_matches=$(grep -i "$1" "Terms/$term/statements" | wc -l | sed 's/ //g')
    grep -i "$1" "Terms/$term/statements" | less -P "$number_of_matches $1 matches found for $term"
    echo "Searched term $term's statements"
  else
    echo "please enter a term to search"
  fi
}

press_any_key_to_escape() {
  tput civis
  read -s -n1 -p "*press any key to escape*"
  tput cnorm
}

change_library() {
  if [[ -n "$1" ]]; then
    if [[ ! -d "../$1" ]]; then
      mkdir "../$1"
      mkdir "../$1/Terms"
      touch "../$1/research.txt"
      echo "Added library \"$1\" with Terms and research.txt. View a list of all libraries with list_libraries or ly"
    fi
    cd "../$1"
    echo "changed current library to $1"
    if [[ $(ls "Terms" | grep "$current_term" ) == "" ]]; then
      current_term="detached"
    fi
  else
    echo "No library was entered. Please try again"
  fi
  update_qdd_prompt
}

list_libraries() {
  number_of_libraries="$(ls .. | cat | wc -l | sed 's/ //g')"
  echo "<-- $number_of_libraries Libraries -->"
  ls -1 ..
}

remove_library() {
  if [[ $(pwd | grep "$1") == "" ]]; then
    read -p "really remove library $1? Reply yes or no only: " remove_confirmation
    if [[ $remove_confirmation == "yes" ]]; then
      rm -r "../$1"
      echo "removed library $1"
      update_qdd_prompt
    else
      echo "ok then."
    fi
  else
    echo "You can't remove a library you are currently in. That would be insane."
  fi
}

wikipedia_citation_removal() {
  cat research.txt | sed 's/\[.*\]//g' >backup
  cp backup research.txt
  rm backup
}

source_qdd() {
  source ../../qdd.sh
  echo "qdd.sh was sourced successfully"
}

gac_qdd_from_anywhere() {
  local message=$*;
  git add /Users/jgolden1/bash/Apps/question_driven_development/.;
  git commit -m "$message"
}

update_qdd_prompt() {
  if [[ -n $current_term ]]; then
    current_term_in_prompt="$current_term"
  else
    current_term_in_prompt="detached"
  fi
  PS1="${RED_FG}\W ${GREEN_FG}${current_term_in_prompt}${MAGENTA_FG} ? \[${NC}\]"
}

#functions between here and aliases are overridden from chat_flippity project

flippity_prompt() {
  if [[ "$1" != "-q" ]]; then #-q is used when no additional prompt from user is desired
    index=0
    echo "Prompt options:"
    echo "Enter - custom prompt"
    echo "^ - copy input line at the top of the screen"
    echo "- - do not add anything to prompt"
    unset questions
    while read question; do
      echo "$index - $question"
      questions+=("$question")
      (( index++ ))
    done <"Terms/$current_term/questions"
    echo
    read -p "Please choose which of the above prompt options you would like to ask chat gippity: " prompt_option <&3
    if [[ $prompt_option =~ [0-9] ]] && [[ ${questions[$prompt_option]} ]]; then
      full_prompt+=${questions[$prompt_option]}
    elif [[ $prompt_option == "^" ]]; then
      full_prompt+="$line"
    elif [[ $prompt_option != "-" ]]; then
      read -p "enter custom prompt here: " prompt
      full_prompt+=$prompt
    fi
  fi
  echo "Current prompt so far = \"${full_prompt}\""
  read -n1 -p "Ready to use prompt? " end_prompt
    echo
    if [[ $end_prompt == "y" ]]; then
      number_of_words=$(echo $full_prompt | wc -w)
      echo "$number_of_words words successfully copied into clipboard"
      echo $full_prompt | pbcopy
      return 0
  else
    full_prompt+=" "
    return 1
  fi
}

verify_question_and_answer() {
  index=0
  unset answers
  echo "Answer options:"
  echo ". - copy most recently added answer"
  echo "^ - copy input line at the top of the screen"
  echo "0 - print array of answers to verify from by index"
  echo "Enter - custom answer"
  echo
  if [[ "$1" == "-q" ]]; then
    start_prompt="Please rate how accurate the following answer(s) are to the following question(s) on a scale of 1-5, 1 being completely inaccurate, and 5 being completely accurate, and provide no explanation as to why."
  else
    start_prompt="Please rate how accurate the following answer(s) are to the following question(s) on a scale of 1-5, 1 being completely inaccurate, and 5 being completely accurate. Then, verify if the following question and answer represent an answer that accurately answers the question, and add any clarification if needed."
  fi
  read -n1 -p "Please choose which of the above answer options you would like chat gippity to verify: " prompt_option <&3
  echo
  if [[ $prompt_option == "^" ]]; then
    question_and_answer="$line"
    echo "Got it. Will attempt to verify the line above in question/answer form."
  elif [[ $prompt_option == "." ]]; then
    question_and_answer="$(tail -1 "Terms/$current_term/answers")"
    echo "Got it. Will verify most recently added answer."
  elif [[ $prompt_option == "0" ]]; then
    while read answer; do
      echo "$index - $answer"
      answers+=("$answer")
      (( index++ ))
    done <"Terms/$current_term/answers"
    read -p "Choose the index of the answer you would like chat gippity to verify: " answer_index <&3
    if [[ "$answer_index" =~ [0-9] && $answer_index -ge 0 && "${answers[$answer_index]}" ]]; then
      question_and_answer="${answers[$answer_index]}"
      echo "Got it. Will verify answer at index $answer_index."
    else
      echo "Question index not recognized, sorry :("
      sleep 0.5
    fi
  else
    read -p "Please enter the question(s) AND answer(s) you want chat gippity to verify (in the form: Question? answer. Question n? answer n.) " question_and_answer
    echo "Got it. Will verify custom answer \"$question_and_answer\"."
  fi
  echo
  full_prompt+="$start_prompt $question_and_answer"
}

alias rfi='research_from_input'
alias qfi='questions_from_input'
alias qfn='questions_from_nothing'
alias qfq='questions_from_questions'
alias qfr='questions_from_research'
alias qfu='questions_from_unanswered_questions'
alias qfz='questions_from_statements'
alias sfa='statements_from_answers'
alias sfaa='statements_from_answers_all'

alias aq='add_question'
alias lq='list questions'
alias luq='list_unanswered_questions'
alias luqa='list_unanswered_questions_all'
alias lqa='list questions all'
alias vq='vim_questions_current_term'

alias aa='add_answer'
alias la='list answers'
alias laa='list answers all'
alias va='vim_answers_current_term'

alias gsfa='get_statement_from_answer'
alias gz='grep_statements_case_sensitive' 
alias gzi='grep_statements_case_insensitive' 
alias gza='lza | grep "\." | grep'
alias lz='list statements'
alias lza='list statements all'
alias vz='vim_statements_current_term'

alias ct='change_term'
alias et='empty_term'
alias lt='list_terms'
alias mt='move_term'
alias rt='remove_term'
alias zt='append_term'

alias ts='term_search'

alias cy='change_library'
alias ly='list_libraries'
alias ry='remove_library'

alias l#='list_numbers'

alias cr='cat research.txt'
alias lr='less -P "%f %P\%" research.txt'
alias vr='vim research.txt'

alias vl='vim links'

alias qdd='source_qdd'
alias qgg='gac_qdd_from_anywhere'
alias qvv='vi /Users/jgolden1/bash/Apps/question_driven_development/qdd.sh'

update_qdd_prompt
