#!/bin/bash
#All functions and aliases relevant to question_driven_development project

#set -u

exec 3<&0
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
              tput civis
              read -s -n1 -p "*press any key to escape*" <&3
              tput cnorm
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
              echo "a = current term's questions"
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
            0)
              echo "$input_file" | questions_from_input
              break 2;
              ;;
            \#)
              list_numbers
              echo
              tput civis
              read -s -n1 -p "*press any key to escape*" <&3
              tput cnorm
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
              read -n1 -p "*press any key to escape*" any_key <&3
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

get_statement_from_answer() {
  should_print="true"
  if [[ -n "$1" ]]; then
    line="$1"
  else
    read line
  fi
  sed_option=""
  if [[ $line =~ "What is" ]] && [[ $line =~ " used for in " ]]; then
    sed_command='s/What is \(.*\) used for in \(.*\)\? \(.*\)/\1 is used for \3 in \2/'
  elif [[ $line =~ "What is" ]] && [[ $line =~ " for in " ]]; then
    sed_command='s/What is \(.*\) for in \(.*\)\? \(.*\)/In \2, \1 is for \3/'
  elif [[ $line =~ "What is" ]] && [[ $line =~ " used for?" ]]; then
    sed_command='s/What is \(.*\) used for\? \(.*\)/\1 is used for \2/'
  elif [[ $line =~ "What is" ]] && [[ $line =~ " for?" ]]; then
    sed_command='s/What is \(.*\) for\? \(.*\)/\1 is for \2/'
  elif [[ $line =~ "What makes a " ]]; then
    sed_command='s/\(What makes a .*\)\? \(.*\)/\1 is \2/'
  elif [[ $line =~ "What " ]] && [[ $line =~ " makes " ]] && [[ $line =~ " get treated " ]]; then
    sed_command='s/What \(.*\) makes \(.*\) get treated \(.*\)\? \(.*\)/The \1 that makes \2 get treated \3 is \4/'
  elif [[ $line =~ "What causes" ]]; then
    sed_command='s/What causes \(.*\)\? \(.*\)/Something that causes \1 is \2/'
  elif [[ $line =~ "According to " ]] && [[ $line =~ "what " ]] && [[ $line =~ is|are|am ]]; then
    sed_option="-r"
    sed_command='s/According to (.*), what ([^ ]+) (.*)\? (.*)/According to \1, \3 \2 \4/'
  elif [[ $line =~ "What is so " ]] && [[ $line =~ " about " ]]; then
    sed_command='s/What is so \(.*\) about \(.*\)\? \(.*\)/Something that is so \1 about \2 is \3/'
  elif [[ $line =~ "What is" ]]; then
    sed_command='s/What is \(.*\)\? \(.*\)/\1 is \2/'
  elif [[ $line =~ "What was" ]]; then
    sed_command='s/What was \(.*\)\? \(.*\)/\1 was \2/'
  elif [[ ! $line =~ "What is" ]] && [[ $line =~ "What " ]] && [[ $line =~ " is " ]]; then
    sed_command='s/What \(.*\) is \(.*\)\? \(.*\)/The \1 that is \2 is \3/'
  elif [[ $line =~ "What are " ]] && [[ $line =~ " used for with " ]]; then
    sed_command='s/What are \(.*\) used for with \(.*\)\? \(.*\)/With \2, \1 are used for \3/'
  elif [[ $line =~ "What are" ]] && [[ $line =~ " used for in " ]]; then
    sed_command='s/What are \(.*\) used for in \(.*\)\? \(.*\)/\1 are used for \3 in \2/'
  elif [[ $line =~ "What are " ]] && [[ $line =~ " used for?" ]]; then
    sed_command='s/What are \(.*\) used for\? \(.*\)/\1 are used for \2/'
  elif [[ $line =~ "What are " ]] && [[ $line =~ " for?" ]]; then
    sed_command='s/What are \(.*\) for\? \(.*\)/\1 are for \2/'
  elif [[ $line =~ "What are" ]]; then
    sed_command='s/What are \(.*\)\? \(.*\)/\1 are \2/'
  elif [[ $line =~ "What am" ]]; then
    sed_command='s/What am \(.*\)\? \(.*\)/\1 am \2/'
  elif [[ $line =~ "What can " ]] && [[ $line =~ "do" ]]; then
    sed_command='s/What can \(.*\) do\(.*\)\? \(.*\)/Something that \1 can do\2 is \3/'
  elif [[ $line =~ "What's" ]]; then
    sed_command="s/What's \(.*\)\? \(.*\)/\1 is \2/"
  elif [[ $line =~ "What difference does " ]] && [[ $line =~ " make" ]]; then
    sed_command='s/What difference does \(.*\) make\(.*\)\? \(.*\)/The difference that \1 makes\2 is \3/'
  elif [[ $line =~ "What do I need in order to " ]]; then
    sed_command='s/What do I need in order to \(.*\)\? \(.*\)/In order to \1, I need \2/'
  elif [[ $line =~ "What does it mean to" ]]; then
    sed_command='s/What does it mean to \(.*\)\? \(.*\)/To \1 means to \2/'
  elif [[ $line =~ "What does it mean when" ]]; then
    sed_command='s/What does it mean when \(.*\)\? \(.*\)/When \1, it means that \2/'
  elif [[ $line =~ "What does it mean for" ]] && [[ $line =~ "to " ]]; then
    sed_command='s/What does it mean for \(.*\) to \(.*\)\? \(.*\)/For \1 to \2 means that \3/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "mean in" ]]; then
    sed_command='s/What does \(.*\) mean in \(.*\)\? \(.*\)/In \2, \1 means \3/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "mean" ]]; then
    sed_command='s/What does \(.*\) mean\? \(.*\)/\1 means \2/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "stand for" ]]; then
    sed_command='s/What does \(.*\) stand for\? \(.*\)/\1 stands for \2/'
  elif [[ $line =~ "What does " ]] && [[ $line =~ " refer to in " ]]; then
    sed_command='s/What does \(.*\) refer to in \(.*\)\? \(.*\)/in \2, \1 refers to \3/'
  elif [[ $line =~ "What does " ]] && [[ $line =~ " refer to?" ]]; then
    sed_command='s/What does \(.*\) refer to\? \(.*\)/\1 refers to \2/'
  elif [[ $line =~ "What does " ]] && [[ $line =~ " allow " ]] && [[ $line =~ " to do?" ]]; then
    sed_command='s/What does \(.*\) allow \(.*\) to do\? \(.*\)/\1 allows \2 to \3/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "do " ]]; then
    sed_option="-r"
    sed_command='s/What does (.*) do ([^ ]+) (.*)\? (.*)/\2 \3, \1 \4/'
  elif [[ $line =~ "What exactly does " ]] && [[ $line =~ " do?" ]]; then
    sed_command='s/What exactly does \(.*\) do\? \(.*\)/\1 \2/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "do?" ]]; then
    sed_command='s/What does \(.*\) do\? \(.*\)/\1 \2/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ " that " ]] && [[ $line =~ " does not?" ]]; then
    sed_option='-r'
    sed_command='s/What does (.*) ([^ ]+) that (.*) does not\? (.*)/What \1 \2s that \3 does not is \4/'
  elif [[ $line =~ "What do" ]] && [[ $line =~ "mean " ]]; then
    sed_command='s/What do \(.*\) mean\(.*\)\? \(.*\)/\2, \1 mean \3/'
  elif [[ $line =~ "What do" ]] && [[ $line =~ "mean" ]]; then
    sed_command='s/What do \(.*\) mean\? \(.*\)/\1 mean \2/'
  elif [[ $line =~ "What do" ]] && [[ $line =~ " that " ]]; then
    sed_command='s/What do \(.*\) do that \(.*\)\? \(.*\)/What \1 do that \2 is \3/'
  elif [[ $line =~ "What do" ]] && [[ $line =~ " do in " ]]; then
    sed_command='s/What do \(.*\) do in \(.*\)\? \(.*\)/In \2, \1 \3/'
  elif [[ $line =~ "What happens" ]]; then
    sed_command='s/What happens \(.*\)\? \(.*\)/\1, \2/'
  elif [[ $line =~ "What did" ]] && [[ $line =~ "do before" ]]; then
    sed_command='s/What did \(.*\) do before \(.*\)\? \(.*\)/Before \2, \1 did \3/'
  elif [[ $line =~ "What role does" ]] && [[ $line =~ "play in" ]]; then
    sed_command='s/What role does \(.*\) play in \(.*\)\? \(.*\)/In \2, \1 plays the role of \3/'
  elif [[ $line =~ "What type of" ]] && [[ $line =~ "is stored in" ]]; then
    sed_command='s/What type of \(.*\) is stored in \(.*\)\? \(.*\)/\3 is stored in \2/'
  elif [[ $line =~ "What types of" ]] && [[ $line =~ "are stored in" ]]; then
    sed_command='s/What types of \(.*\) are stored in \(.*\)\? \(.*\)/\3 \1 are stored in \2/'
  elif [[ $line =~ "What steps does " ]] && [[ $line =~ " take to " ]]; then
    sed_command='s/What steps does \(.*\) take to \(.*\)\? \(.*\)/The steps \1 takes to \2 are \3/'
  elif [[ $line =~ "What" ]] && [[ $line =~ " would " ]] && [[ $line =~ " use to " ]]; then
    sed_option="-r"
    sed_command='s/What (.*) would ([^ ]+) use to (.*)\?/\2 would use \1 to \3/'
  elif [[ $line =~ "What " ]] && [[ $line =~ " are " ]]; then
    sed_command='s/What \(.*\)s are \(.*\)\? \(.*\)/Some \1s that are \2 include \3/'
  elif [[ $line =~ "Where is " ]] && [[ $line =~ " stored?" ]]; then
    sed_command='s/Where is \(.*\) stored\? \(.*\)/\1 is stored \2/'
  elif [[ $line =~ "Where is " ]] && [[ $line =~ " located?" ]]; then
    sed_command='s/Where is \(.*\) located\? \(.*\)/\1 is located \2/'
  elif [[ $line =~ "Where do " ]] && [[ $line =~ " get " ]] && [[ $line =~ "ed?" ]]; then
    sed_command='s/Where do \(.*\) get \(.*\)ed\? \(.*\)/\1 get \2ed \3/'
  elif [[ $line =~ "When should" ]]; then
    sed_option="-r"
    sed_command='s/When should ([^ ]+) (.*)\? (.*)/\1 should \2 when \3/'
  elif [[ $line =~ "When" ]] && [[ $line =~ "what" ]] && [[ $line =~ "must" ]]; then
    sed_command='s/When \(.*\), what \(.*\) must \(.*\)\? \(.*\)/When \1, the \2 that \3 is \4/'
  elif [[ $line =~ "When does " ]] && [[ $line =~ start ]]; then
    sed_command='s/When does \(.*\) start \(.*\)\? \(.*\)/\1 starts \2 when \3/'
  elif [[ $line =~ "When does " ]] && [[ $line =~ stop ]]; then
    sed_command='s/When does \(.*\) stop \(.*\)\? \(.*\)/\1 stops \2 when \3/'
  elif [[ $line =~ "When might " ]]; then
    sed_command='s/When might \(.*\)\? \(.*\)/I might \1 \2/'
  elif [[ $line =~ "What would cause" ]]; then
    sed_command='s/What would cause \(.*\)\? \(.*\)/\2 would cause \1/'
  elif [[ $line =~ "Which " ]] && [[ $line =~ "represents" ]]; then
    sed_command='s/Which \(.*\) represents \(.*\)\? \(.*\)/The \1 which represents \2 is \3/'
  elif [[ $line =~ "Which" ]] && [[ $line =~ "turns" ]]; then
    sed_command='s/Which \(.*\) turns \(.*\)\? \(.*\)/The \1 that turns \2 is \3/'
  elif [[ $line =~ "Which " ]] && [[ $line =~ "breaks" ]]; then
    sed_command='s/Which \(.*\) breaks \(.*\)\? \(.*\)/The \1 which breaks \2 is \3/'
  elif [[ $line =~ "Which " ]] && [[ $line =~ "lists" ]]; then
    sed_command='s/Which \(.*\) lists \(.*\)\? \(.*\)/The \1 which lists \2 is \3/'
  elif [[ $line =~ "Which " ]] && [[ $line =~ " are " ]]; then
    sed_command='s/Which \(.*\) are \(.*\)? \(.*\)/The \1 which are \2 are \3/'
  elif [[ $line =~ "Which " ]] && [[ $line =~ " is " ]]; then
    sed_command='s/Which \(.*\) is \(.*\)? \(.*\)/The \1 which is \2 is \3/'
  elif [[ $line =~ "Which " ]] && [[ $line =~ " converts " ]] && [[ $line =~ " to " ]]; then
    sed_command='s/Which \(.*\) converts \(.*\) to \(.*\)? \(.*\)/The \1 that converts \2 to \3 is \4/'
  elif [[ $line =~ "Why is" ]] && [[ $line =~ " a " ]]; then
    sed_command='s/Why is \(.*\) a \(.*\)\? \(.*\)/\1 is a \2 because \3/'
  elif [[ $line =~ "Why is " ]] && [[ $line =~ " so " ]]; then
    sed_command='s/Why is \(.*\) so \(.*\)\? \(.*\)/\1 is so \2 because \3/'
  elif [[ $line =~ "Why is " ]] && [[ $line =~ " in " ]]; then
    sed_option='-r'
    sed_command='s/Why is (.*) ([^ ]+) in (.*)\? (.*)/\1 is \2 in \3 because \4/'
  elif [[ $line =~ "Why is" ]]; then
    sed_command='s/Why is \(.*\) \(.*\)\? \(.*\)/\1 is \2 because \3/'
  elif [[ $line =~ "Why are" ]] && [[ $line =~ "ed " ]]; then
    sed_option='-r'
    sed_command='s/Why are (.*) ([^ ]+)ed (.*)\? (.*)/\1 are \2ed \3 because \4/'
  elif [[ $line =~ "Why are" ]]; then
    sed_command='s/Why are \(.*\) \(.*\)\? \(.*\)/\1 are \2 because \3/'
  elif [[ $line =~ "Why am" ]]; then
    sed_command='s/Why am \(.*\) \(.*\)\? \(.*\)/\1 am \2 because \3/'
  elif [[ $line =~ "Why doesn't " ]]; then
    sed_option="-r"
    sed_command="s/Why doesn't ([^ ]+) (.*)\? (.*)/\1 doesn't \2 because \3/"
  elif [[ $line =~ "Why does" ]]; then
    sed_option="-r"
    sed_command='s/Why does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 because \4/'
  elif [[ $line =~ "Why did " ]] && [[ $line =~ "wear" ]]; then
    sed_command='s/Why did \(.*\) wear \(.*\)\? \(.*\)/\1 wore \2 because \3/'
  elif [[ $line =~ "Why did " ]] && [[ $line =~ "own" ]]; then
    sed_command='s/Why did \(.*\) own \(.*\)\? \(.*\)/\1 owned \2 because \3/'
  elif [[ $line =~ "Why did " ]] && [[ $line =~ " respect " ]]; then
    sed_command='s/Why did \(.*\) respect \(.*\)\? \(.*\)/\1 respected \2 because \3/'
  elif [[ $line =~ "Why should" ]]; then
    sed_option="-r"
    sed_command='s/Why should ([^ ]+) (.*)\? (.*)/\1 should \2 because \3/'
  elif [[ $line =~ "Why might" ]]; then
    sed_option="-r"
    sed_command='s/Why might ([^ ]+) (.*)\? (.*)/\1 might \2 because \3/'
  elif [[ $line =~ "Why can " ]] && [[ $line =~ " be " ]]; then
    sed_command='s/Why can \(.*\) be \(.*\)\? \(.*\)/\1 can be \2 because \3/'
  elif [[ $line =~ "Why do I " ]]; then
    sed_command='s/Why do I \(.*\)\? \(.*\)/I \1 because \2/'
  elif [[ $line =~ "Why do " ]] && [[ $line =~ " exist?" ]]; then
    sed_command='s/Why do \(.*\) exist\? \(.*\)/\1 exist \2/'
  elif [[ $line =~ "Why do " ]]; then
    sed_command='s/Why do \(.*\) do \(.*\)\? \(.*\)/\1 do \2 \3/'
  elif [[ $line =~ "In what circumstance would" ]] && [[ $line =~ "use" ]]; then
    sed_option="-r"
    sed_command='s/In what circumstance would ([^ ]+) use (.*)\? (.*)/\1 would use \2 if \3/'
  elif [[ $line =~ "Under what circumstances does" ]]; then
    sed_option="-r"
    sed_command='s/Under what circumstances does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 if \4/'
  elif [[ $line =~ "Under what circumstances" ]]; then
    sed_option="-r"
    sed_command='s/Under what circumstances ([^ ]+) ([^ ]+) (.*)\? (.*)/\2 \1 \3 if \4/'
  elif [[ $line =~ "Should I " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no, " && sed_command='s/Should I ([^ ]+) (.*)\? ([^ ]+) (.*)/No, I should NOT \1 \2, because \4/' || sed_command='s/Should I ([^ ]+) (.*)\? ([^ ]+) (.*)/Yes, I SHOULD \1 \2, because \4/' 
  elif [[ $line =~ "How are" ]] && [[ $line =~ " made to " ]]; then
    sed_command='s/How are \(.*\) made to \(.*\)\? \(.*\)/\1 are made to \2 by \3/'
  elif [[ $line =~ "How does" ]] && [[ $line =~ " a " ]]; then
    sed_option="-r"
    sed_command='s/How does a ([^ ]+) ([^ ]+)(.*)\? (.*)/A \1 \2s\3 by \4/'
  elif [[ $line =~ "How does" ]] && [[ $line =~ "work?" ]]; then
    sed_command='s/How does \(.*\) work\? \(.*\)/\1 works by \2/'
  elif [[ $line =~ "How does" ]]; then
    sed_option="-r"
    sed_command='s/How does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 by \4/'
  elif [[ $line =~ "How do" ]]; then
    sed_command='s/How do \(.*\)\? \(.*\)/\1 by \2/'
  elif [[ $line =~ "How can" ]]; then
    sed_option="-r"
    sed_command='s/How can ([^ ]+) (.*)\? (.*)/\1 can \2 by \3/'
  elif [[ $line =~ "How is" ]] && [[ $line =~ "ed" ]]; then
    sed_command='s/How is \(.*\) \(.*\)ed\(.*\)\? \(.*\)/\1 is \2ed\3 \4/'
  elif [[ $line =~ "How is a" ]] && [[ $line =~ "ed" ]]; then
    sed_command='s/How is a \(.*\) \(.*\)ed\(.*\)\? \(.*\)/A \1 is \2ed\3 \4/'
  elif [[ $line =~ "How would I " ]]; then
    sed_command='s/How would I \(.*\)\? \(.*\)/I would \1 by \2/'
  elif [[ $line =~ "How has " ]]; then
    sed_command='s/How has \(.*\) blessed \(.*\)\? \(.*\)/\1 has blessed \2 by \3/'
  elif [[ $line =~ "Is it possible to" ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is it possible to (.*)\? ([^ ]+), (.*)/It is NOT possible to \1 because \3/' || sed_command='s/Is it possible to (.*)\? ([^ ]+), (.*)/It IS possible to \1 because \3/'
  elif [[ $line =~ "Is there a way" ]] && [[ $line =~ " to " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is there a way (.*) to (.*)\? ([^ ]+), (.*)/No, there is NOT a way \1 to \2 -- \4/' || sed_command='s/Is there a way (.*) to (.*)\? ([^ ]+), (.*)/Yes, there IS a way \1 to \2 -- \4/'
  elif [[ $line =~ "Is" ]] && [[ $line =~ "necessary for " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is (.*) necessary for (.*)\? ([^ ]+), (.*)/\1 is NOT necessary for \2 because \4/' || sed_command='s/Is (.*) necessary for (.*)\? ([^ ]+), (.*)/\1 IS necessary for \2 because \4/'
  elif [[ $line =~ "Is" ]] && [[ $line =~ " needed in the context of " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is (.*) needed in the context of (.*)\? ([^ ]+), (.*)/\1 is NOT needed in the context of \2 because \4/' || sed_command='s/Is (.*) needed in the context of (.*)\? ([^ ]+), (.*)/\1 IS needed in the context of \2 because \4/'
  elif [[ $line =~ "Is it true that" ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is it true that (.*)\? ([^ ]+), (.*)/It is NOT true that \1 because \3/' || sed_command='s/Is it true that (.*)\? ([^ ]+), (.*)/It IS true that \1 because \3/'
  elif [[ $line =~ "Is " ]] && [[ $line =~ " a " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is (.*) a (.*)\? ([^ ]+), (.*)/no, \1 is NOT a \2 because \4/' || sed_command='s/Is (.*) a (.*)\? ([^ ]+), (.*)/Yes, \1 IS a \2 because \4/'
  elif [[ $line =~ "Was " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Was (.*) ([^ ]+)\? ([^ ]+), (.*)/\1 was NOT \2 because \4/' || sed_command='s/Was (.*) ([^ ]+)\? ([^ ]+), (.*)/\1 WAS \2 because \4/'
  elif [[ $line =~ "How " ]] && [[ $line =~ "ould you " ]]; then
    sed_command='s/How \(.*ould\) you \(.*\)\? \(.*\)/You \1 \2 by \3/'
  elif [[ $line =~ "Does" ]] && [[ $line =~ "have to" ]]; then
    echo "$line" | grep -qi "no," && sed_command='s/Does \(.*\) have to \(.*\)\? \(.*\), \(.*\)/\1 does NOT have to \2 because \4/' || sed_command='s/Does \(.*\) have to \(.*\)\? \(.*\)/\1 DOES have to \2 because \3/'
  elif [[ $line =~ "Does" ]] && [[ $line =~ "only " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no, " && sed_command='s/Does (.*) only (.*)\? ([^ ]+) (.*)/No, \1 does NOT only \2 because \4/' || sed_command='s/Does (.*) only (.*)\? ([^ ]+) (.*)/Yes, \1 DOES only \2 because \4/' 
  elif [[ $line =~ "Do" ]] && [[ $line =~ " always " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no, " && sed_command='s/Do (.*) always (.*)\? ([^ ]+) (.*)/No, \1 do NOT always \2 because \4/' || sed_command='s/Do (.*) always (.*)\? ([^ ]+) (.*)/Yes, \1 DO always \2 because \4/' 
  elif [[ $line =~ "Can" ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no, " && sed_command="s/Can ([^ ]+) (.*)\? ([^ ]+) (.*)/No, \1 CAN'T \2--\4/" || sed_command="s/Can ([^ ]+) (.*)\? ([^ ]+) (.*)/Yes, \1 CAN \2--\4/"
  elif [[ $line =~ "Are " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Are (.*)s (.*)\? ([^ ]+), (.*)/no, \1s are NOT \2 because \4/' || sed_command='s/Are (.*)s (.*)\? ([^ ]+), (.*)/yes, \1s ARE \2 because \4/'
  else
    return
  fi
  if [[ -n $sed_option ]]; then
    echo "$line" | sed "$sed_option" "$sed_command" | capitalize_first_letter
  else
    echo "$line" | sed "$sed_command" | capitalize_first_letter
  fi
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
        read -p "Jump to flashcard #" fc_number
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
  number_of_terms="$(ls Terms | cat | wc -l | sed 's/.*\([0-9]\)/\1/')"
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
