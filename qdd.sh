#!/bin/bash
#All functions and aliases relevant to question_driven_development project

#set -u

exec 3<&0
current_q_category="${current_q_category:-}"
match=

BLACK_FG=$'\033[38:5:0m'
RED_FG=$'\033[30;31m'
GREEN_FG=$'\033[30;32m'
MAGENTA_FG=$'\033[30;35m'
GOLD_BG=$'\033[48:5:3m'
GREY_BG=$'\033[48:5:7m'
RED_BG=$'\033[30;101m'
GREEN_BG=$'\033[30;102m'
BLUE_BG=$'\033[30;104m'
NC=$'\033[0m'
NL=$'\n'

questions_from_input() {
  if [[ -n "$current_q_category" ]]; then
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
          echo "${BLACK_FG}${GREY_BG}line $line_number of $input_length ${GOLD_BG} ${percent}% ${RED_BG} "$(pwd | sed 's/.*\///g')" ${GREEN_BG} ${current_q_category} ${BLUE_BG} ❓ ${NC}"
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
              list_q_categories
              echo
              read -p "Change q_category $current_q_category to: " new_q_category <&3
              change_q_category "$new_q_category"
              sleep 0.75
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
              done <"Q_categories/$current_q_category/questions"
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
							help_log+="a = [a]dd a question to current q_category's questions file${NL}"
              help_log+="b = go [b]ack 1 input line${NL}" 
              help_log+="c = list and change current q_[c]ategory${NL}" 
              help_log+="g = [g]oogle user input${NL}" 
              help_log+="G = [G]oogle one of current q_category's questions${NL}"
							help_log+="h = display qfi command [h]elp${NL}"
              help_log+="j = [j]ump to input line by number${NL}" 
              help_log+="k = open lin[k] by index from link file in new google tab${NL}" 
              help_log+="l = open [l]ist menu for questions, answers, statements, q_categories, libraries, sections, etc${NL}" 
              help_log+="m = go to book[m]ark${NL}" 
              help_log+="n = [n]ext input line${NL}" 
							help_log+="N = combi[N]e current line with next line and show as one line${NL}"
							help_log+="o = view [o]riginal line (no combined inputs)${NL}"
              help_log+="p = a[p]pend current line to research.txt${NL}" 
              help_log+="q = [q]uit qfi${NL}" 
              help_log+="s = [s]ection hopper${NL}" 
              help_log+="w = ans[w]er one of the current q_category's questions${NL}"
              help_log+="W = ans[W]er one of the current q_category's unanswered questions${NL}" 
              help_log+="y = list all libraries and change current librar[y]${NL}" 
              help_log+="0 = go to beginning of input lines (works like vim's [0])${NL}"
              help_log+="$ = go to end of input lines (works like vim's [$])${NL}" 
              help_log+="^ = google current input line and copy it to clipboard [^]${NL}" 
              help_log+="& = copy current input line to clipboard [&]${NL}" 
              help_log+="/ = search for a string in input lines (from current location, works like vim's [/])"
              echo "$help_log" | less -e -P "q or j to exit"
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
              index=0
              while read link; do
                link_name=$(echo "$link" | sed 's/\(.*\): .*/\1/')
                relevant_link=$(echo "$link" | sed 's/.*: \(.*\)/\1/')
                list_of_links+=("$relevant_link")
                echo "$index - $link_name"
                (( index++ ))
              done < links
              read -p "Type the index of the link you want to open: " link_index <&3
              if [[ "$link_index" ]] && [[ $link_index -lt "${#list_of_links}" ]]; then
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
              read -s -n1 -p "What would you like to list?"$'\n'"a/A - answers, c - q_categories, l/L - answers, questions, and statements, q/Q - questions, s - sections, u/U - unanswered, y - libraries, z/Z - statements. lowercase = current q_category; UPPERCASE = ALL q_categories."$'\n' list_op <&3
              case $list_op in 
              a)
                list answers
                ;;
              A)
                list answers all
                ;;
              c)
                list_q_categories
                ;;
              l)
                list
                ;;
              L)
                list all
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
            w|W)
              questions=()
              index=0
              [[ $input == "W" ]] && echo "UNANSWERED:"
              while read question; do
                if [[ "$input" == "W" ]]; then
                  grep -q "$question" "Q_categories/$current_q_category/answers" && continue
                fi
                questions+=("$question");
                echo "$index - $question"
                (( index++ ))
              done <"Q_categories/$current_q_category/questions"
              if [[ ${#questions} -gt 0 ]]; then
                echo
                read -p "Please choose which of the above questions you would like to answer: " q_ind <&3
                if [[ -n $q_ind ]] && [[ ! "$q_ind" =~ [a-zA-Z] ]] && [[ -n ${questions[$q_ind]} ]]; then
                  echo
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
                [[ $input == 'w' ]] && echo "No questions found for $current_q_category." || echo "No unanswered questions found for $current_q_category."
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
            0)
              echo "$input_file" | questions_from_input
              break 2;
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
            "&")
              if [[ -n $line ]]; then
                line_to_copy=$(echo "$line" | sed 's/UNANSWERED: //')
                echo $line_to_copy | pbcopy
                echo "line copied to clipboard"
                sleep 0.5
              fi
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
    echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
  fi
}

questions_from_nothing() {
	echo "nothing" | questions_from_input "$1"
}

questions_from_questions() {
  questions=""
  while read question; do
    grep -q "$question" "Q_categories/$current_q_category/answers" && questions+="$question " || questions+="UNANSWERED: $question "
  done < <(list questions | sed '1d')
  echo $questions | questions_from_input "$1"
}

questions_from_research() {
  cat research.txt | questions_from_input "$1"
}

questions_from_statements() {
  [[ -f "Q_categories/$current_q_category/statements" ]] && cat "Q_categories/$current_q_category/statements" | questions_from_input "$1"
}

statements_from_answers() {
  [[ -n "$1" ]] && q_category="$1" || q_category="$current_q_category"
  empty_file "Q_categories/$q_category/statements"
  while read line; do
    echo "$(get_statement_from_answer "$line")." >>"Q_categories/$q_category/statements"
  done <"Q_categories/$q_category/answers"
  number="$(cat "Q_categories/$q_category/statements" | cat | wc -l | sed 's/ //g')"
  echo "<-- $number statements about $q_category -->"
  cat "Q_categories/$q_category/statements"
}

statements_from_answers_all() {
  while read q_category; do
    statements_from_answers "$q_category"
  done < <(ls Q_categories)
}

get_statement_from_answer() {
  should_print="true"
  if [[ -n "$1" ]]; then
    line="$1"
  else
    read line
  fi
  sed_option=""
  if [[ $line =~ "What is" ]] && [[ $line =~ "for\?" ]]; then
    sed_option="-r"
    sed_command='s/What is (.*) ([^ ]+) for\? (.*)/\1 is \2 for \3/'
  elif [[ $line =~ "What is" ]]; then
    sed_command='s/What is \(.*\)\? \(.*\)/\1 is \2/'
  elif [[ $line =~ "What are" ]]; then
    sed_command='s/What are \(.*\)\? \(.*\)/\1 are \2/'
  elif [[ $line =~ "What am" ]]; then
    sed_command='s/What am \(.*\)\? \(.*\)/\1 am \2/'
  elif [[ $line =~ "What does it mean to" ]]; then
    sed_command='s/What does it mean to \(.*\)\? \(.*\)/To \1 means to \2/'
  elif [[ $line =~ "What does it mean for" ]] && [[ $line =~ "to be" ]]; then
    sed_command='s/What does it mean for \(.*\) to be \(.*\)\? \(.*\)/For \1 to be \2 means that \3/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "mean" ]]; then
    sed_command='s/What does \(.*\) mean\? \(.*\)/\1 means \2/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "stand for" ]]; then
    sed_command='s/What does \(.*\) stand for\? \(.*\)/\1 stands for \2/'
  elif [[ $line =~ "What does" ]] && [[ $line =~ "do" ]]; then
    sed_command='s/What does \(.*\) do\? \(.*\)/\1 \2/'
  elif [[ $line =~ "What happens" ]]; then
    sed_command='s/What happens \(.*\)\? \(.*\)/\1, \2/'
  elif [[ $line =~ "What did" ]] && [[ $line =~ "do before" ]]; then
    sed_command='s/What did \(.*\) do before \(.*\)\? \(.*\)/Before \2, \1 did \3/'
  elif [[ $line =~ "What type of" ]] && [[ $line =~ "is stored in" ]]; then
    sed_option="-r"
    sed_command='s/What type of ([^ ]+) is stored in (.*)\? (.*)/\3 is stored in \2/'
  elif [[ $line =~ "When should" ]]; then
    sed_option="-r"
    sed_command='s/When should ([^ ]+) (.*)\? (.*)/\1 should \2 when \3/'
  elif [[ $line =~ "Why is" ]] && [[ $line =~ "so" ]]; then
    sed_command='s/Why is \(.*\) so \(.*\)\? \(.*\)/\1 is so \2 because \3/'
  elif [[ $line =~ "Why is" ]]; then
    sed_command='s/Why is \(.*\) \(.*\)\? \(.*\)/\1 is \2 because \3/'
  elif [[ $line =~ "Why are" ]]; then
    sed_command='s/Why are \(.*\) \(.*\)\? \(.*\)/\1 are \2 because \3/'
  elif [[ $line =~ "Why am" ]]; then
    sed_command='s/Why am \(.*\) \(.*\)\? \(.*\)/\1 am \2 because \3/'
  elif [[ $line =~ "Why does" ]]; then
    sed_option="-r"
    sed_command='s/Why does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 because \4/'
  elif [[ $line =~ "Why should" ]]; then
    sed_option="-r"
    sed_command='s/Why should ([^ ]+) (.*)\? (.*)/\1 should \2 because \3/'
  elif [[ $line =~ "Why might" ]]; then
    sed_option="-r"
    sed_command='s/Why might ([^ ]+) (.*)\? (.*)/\1 might \2 because \3/'
  elif [[ $line =~ "Under what circumstances does" ]]; then
    sed_option="-r"
    sed_command='s/Under what circumstances does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 if \4/'
  elif [[ $line =~ "Under what circumstances" ]]; then
    sed_option="-r"
    sed_command='s/Under what circumstances ([^ ]+) ([^ ]+) (.*)\? (.*)/\2 \1 \3 if \4/'
  elif [[ $line =~ "How does" ]]; then
    sed_option="-r"
    sed_command='s/How does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 by \4/'
  elif [[ $line =~ "How do" ]]; then
    sed_command='s/How do \(.*\)\? \(.*\)/\1 by \2/'
  elif [[ $line =~ "How can" ]]; then
    sed_option="-r"
    sed_command='s/How can ([^ ]+) (.*)\? (.*)/\1 can \2 by \3/'
  elif [[ $line =~ "Is it true that" ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is it true that (.*)\? ([^ ]+), (.*)/It is NOT true that \1 because \3/' || sed_command='s/Is it true that (.*)\? ([^ ]+). (.*)/It IS true that \1 because \3/'
  elif [[ $line =~ "Does" ]] && [[ $line =~ "have to" ]]; then
    echo "$line" | grep -qi "no," && sed_command='s/Does \(.*\) have to \(.*\)\? \(.*\), \(.*\)/\1 does NOT have to \2 because \4/' || sed_command='s/Does \(.*\) have to \(.*\)\? \(.*\)/\1 DOES have to \2 because \3/'
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
      last_q_category="$(ls Q_categories | tail -1)"
      for q_category in $(ls Q_categories); do
        echo "[ $q_category ]"
        number="$(cat "Q_categories/$q_category/$1" | cat | wc -l | sed 's/ //g')"
        echo "<-- $number $1 about $q_category -->"
        cat "Q_categories/$q_category/$1"
        if [[ $q_category != $last_q_category ]]; then
          echo
        fi
      done
    elif [[ -n $current_q_category ]]; then
      number="$(cat "Q_categories/$current_q_category/$1" | cat | wc -l | sed 's/ //g')"
      echo "<-- $number $1 about $current_q_category -->"
      cat "Q_categories/$current_q_category/$1"
    else
      echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
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
    echo "First parameter was incorrect. After list, please type \"questions\", \"answers\", or \"statements\". Calling list with no parameters lists questions, answers, and statements for current q_category. Calling list all lists questions, answers, and statements for ALL q_categories in current library."
  fi
}

add_answer() { #$1 = question, $2 = answer
  if [[ -n $current_q_category ]]; then
    if [[ "$1" =~ "?" ]] && [[ "$2" != "" ]]; then
      grep -q "$1" "Q_categories/$current_q_category/questions" || add_question "$1"
      echo "$1 $2" >>"Q_categories/$current_q_category/answers" && echo "answer was added to $current_q_category answers" || echo "ERROR: question was not added to $current_q_category answers."
    else
      echo "question and/or answer was invalid"
    fi
  else
    echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
  fi
}

vim_answers_current_q_category() {
  if [[ -n $current_q_category ]]; then
    vi "Q_categories/$current_q_category/answers"
  else
    echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
  fi
}

add_question() {
  if [[ -n $current_q_category ]]; then
    if [[ $1 =~ "?" ]]; then
      echo "$1" >>"Q_categories/$current_q_category/questions" && echo "question was added to $current_q_category questions" || echo "ERROR: question was not added to $current_q_category questions."
    else
      echo "Invalid question format."
    fi
  else
    echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
  fi
}

list_unanswered_questions() {
  [[ -n "$1" ]] && q_category="$1" || q_category="$current_q_category"
  if [[ -n $q_category ]]; then
    unanswered_questions=""
    while read question; do
      if [[ "$(grep "$question" "Q_categories/$q_category/answers")"  == "" ]]; then
        unanswered_questions+="$question\n"
      fi
    done <"Q_categories/$q_category/questions"
    unanswered_questions="${unanswered_questions%'\n'}"
    if [[ -n $unanswered_questions ]]; then
      number_of_unanswered_questions="$(echo -e $unanswered_questions | wc -l | sed 's/^[[:space:]]*//')"
      echo -e "<-- $number_of_unanswered_questions unanswered questions about $q_category -->"
      echo -e "$unanswered_questions"
    else
      echo -e "<-- 0 unanswered questions about $q_category -->"
    fi
  else
    echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
  fi
}

list_unanswered_questions_all() {
  while read q_category; do
    echo "[ $q_category unanswered questions ]"
    list_unanswered_questions "$q_category"
    echo
  done < <(ls Q_categories)
}

vim_questions_current_q_category() {
  if [[ -n $current_q_category ]]; then
    vi "Q_categories/$current_q_category/questions"
  else
    echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
  fi
}

vim_statements_current_q_category() {
  if [[ -n $current_q_category ]]; then
    vi "Q_categories/$current_q_category/statements"
  else
    echo "You have not yet defined a current q_category. Please do so with change_q_category, then try again."
  fi
}

append_q_category() {
  if [[ "$1" ]] && [[ $(ls Q_categories | grep "$1") != "" ]]; then 
    cat Q_categories/$current_q_category/questions >>Q_categories/$1/questions
    cat Q_categories/$current_q_category/answers >>Q_categories/$1/answers
    cat Q_categories/$current_q_category/statements >>Q_categories/$1/statements
    echo "appended current q category current_q_category to \""$1"\" category"
  else
    echo "Invalid q category"
  fi
}

change_q_category() { 
  if [[ -n "$1" ]]; then
    if [[ ! -d "Q_categories/$1" ]]; then
      mkdir "Q_categories/$1"
      touch "Q_categories/$1/answers" "Q_categories/$1/questions" "Q_categories/$1/statements"
      echo "Added directory $1 to Q_categories, with answers, questions, and statements files. View a list of all q_categories with list_q_categories or lt"
    fi
    current_q_category="$1"
    echo "changed current q_category to $current_q_category"
  else
    echo "q_category was invalid."
  fi
  update_qdd_prompt
}

empty_q_category() {
	if [[ "$1" ]]; then
		q_category_to_empty="$1"
	else
		q_category_to_empty="$current_q_category"
	fi
	if [[ -d "Q_categories/$q_category_to_empty" ]]; then
		read -p "Are you sure you want to empty q category \"$current_q_category\"? " user_confirmation
		if [[ $user_confirmation =~ y|Y ]]; then
			empty_file Q_categories/$current_q_category/questions
			empty_file Q_categories/$current_q_category/answers
			empty_file Q_categories/$current_q_category/statements
			echo "Emptied q category \"$current_q_category\""
		else
			echo "Ok, no emptying will take place"
		fi
	else
	  echo "Invalid q category"
	fi
}

list_q_categories() {
  number_of_q_categories="$(ls Q_categories | cat | wc -l | sed 's/.*\([0-9]\)/\1/')"
  echo "<-- $number_of_q_categories Q_categories -->"
  ls -1 Q_categories
}

move_q_category() {
  if [[ -n "$1" ]]; then
    mv "Q_categories/$current_q_category" "Q_categories/$1"
    touch "Q_categories/$1/answers" "Q_categories/$1/questions" "Q_categories/$1/statements"
    rm -rf "Q_categories/$current_q_category"
    current_q_category="$1"
    echo "Moved $current_q_category to $1."
  else
    echo "q_category was invalid."
  fi
  update_qdd_prompt
}

remove_q_category() {
  rm -r "Q_categories/$1"
  echo "removed q_category $1"
  if [[ $current_q_category == "$1" ]]; then
    current_q_category="detached"
  fi
  update_qdd_prompt
}

change_library() {
  if [[ -n "$1" ]]; then
    if [[ ! -d "../$1" ]]; then
      mkdir "../$1"
      mkdir "../$1/Q_categories"
      touch "../$1/research.txt"
      echo "Added library \"$1\" with Q_categories and research.txt. View a list of all libraries with list_libraries or ly"
    fi
    cd "../$1"
    echo "changed current library to $1"
    if [[ $(ls "Q_categories" | grep "$current_q_category" ) == "" ]]; then
      current_q_category="detached"
    fi
  else
    echo "No library was entered. Please try again"
  fi
  update_qdd_prompt
}

list_libraries() {
  number_of_libraries="$(ls .. | cat | wc -l | sed 's/.*\([0-9]\)/\1/')"
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

remove_wikipedia_citations() {
  cat research.txt | sed 's/\[.*\]//g' >backup
  cp backup research.txt
  rm backup
}

source_qdd() {
  source ../../qdd.sh
  echo "qdd.sh was sourced successfully"
}

update_qdd_prompt() {
  if [[ -n $current_q_category ]]; then
    current_q_category_in_prompt="$current_q_category"
  else
    current_q_category_in_prompt="detached"
  fi
  PS1="${RED_FG}\W ${GREEN_FG}${current_q_category_in_prompt}${MAGENTA_FG} ? ${NC}"
}

alias rfi='research_from_input'
alias qfi='questions_from_input'
alias qfn='questions_from_nothing'
alias qfq='questions_from_questions'
alias qfr='questions_from_research'
alias qfs='questions_from_statements'
alias sfa='statements_from_answers'
alias sfaa='statements_from_answers_all'

alias aq='add_question'
alias lq='list questions'
alias luq='list_unanswered_questions'
alias luqa='list_unanswered_questions_all'
alias lqa='list questions all'
alias vq='vim_questions_current_q_category'

alias aa='add_answer'
alias la='list answers'
alias laa='list answers all'
alias va='vim_answers_current_q_category'

alias gsfa='get_statement_from_answer'
alias lz='list statements'
alias lza='list statements all'
alias vz='vim_statements_current_q_category'

alias qc='change_q_category'
alias aqc='append_q_category'
alias eqc='empty_q_category'
alias lqc='list_q_categories'
alias mqc='move_q_category'
alias rqc='remove_q_category'

alias cy='change_library'
alias ly='list_libraries'
alias ry='remove_library'

alias qdd='source_qdd'
alias cr='cat research.txt'
alias lr='less -P "%f %P\%" research.txt'
alias vr='vi research.txt'

update_qdd_prompt
