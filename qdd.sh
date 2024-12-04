#!/bin/bash
#All functions and aliases relevant to question_driven_development project

exec 3<&0
current_term="$current_term"

questions_from_input() {
	if [[ -n $current_term ]]; then
		line_number=1
		input_file=$(cat)
		input_length="$(echo "$input_file" | sentencify | wc -l | sed 's/ //g')"
		[[ -n $1 ]] && line_start="$1" || line_start=1
		echo "$input_file" | sentencify | while IFS= read -r line; do
			if [[ $line == "" ]] || [[ $line == " " ]]; then
				continue
			else
				while : ; do
					[[ $line_number -lt $line_start ]] && break
					BLACK_FG='\033[38:5:0m'
					GREY='\033[48:5:7m'
					RED='\033[30;101m'
					GOLD='\033[48:5:3m'
					GREEN='\033[30;102m'
					BLUE='\033[30;104m'
					NC='\033[0m'
					percent="$(perl -e "print int($line_number / $input_length * 100 + 0.5)")"
					printf "\033c"
					echo $line
					echo -ne "${BLACK_FG}${GREY}line $line_number ${GOLD} ${percent}% ${RED} "$(pwd | sed 's/.*\///g')" ${GREEN} ${current_term} ${BLUE} ❓ ${NC} => a = ask, b = back, c = change, g/G = google (q), j/J = jump (end), l = list, n = next, q = quit, r = restart, w/W = answer (unanswered), y = library"$'\n'
					read -n1 -r -s input <&3
					case $input in
						"a")
							read -p "Enter question here: " question <&3
							add_question "$question"
							sleep 1
							;;
						"b")
							if [[ $line_number -gt 1 ]]; then
								echo "$input_file" | questions_from_input "$(( $line_number - 1 ))"
								break 2
							else
								echo "Cannot go back."
								sleep 0.5
							fi
							;;
						"c")
							read -p "Change term $current_term to: " new_term <&3
							change_term "$new_term"
							sleep 1
							;;
						"g")
							read -p "What do you want to look up?: " search <&3
							if [[ -n $search ]]; then
								echo "$search" | pbcopy
								google "$search"
							else
								echo "invalid search request"
								sleep 0.5
							fi
							;;
						"G")
							questions=()
							index=0
							while read question; do
								questions+=("$question");
								echo "$index - $question"
								(( index++ ))
							done <"Terms/$current_term/questions"
							read -p "please choose which of the above questions to google and copy to clipboard: " q_ind <&3
							if [[ ! "$q_ind" =~ [a-zA-Z] ]] && [[ -n ${questions[$q_ind]} ]]; then
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
						"j")
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
						"J")
								echo "$input_file" | questions_from_input "$input_length"
								break 2
							;;
						"l")
							read -s -n1 -p "What would you like to list?"$'\n'"a/A - answers, l/L - answers, questions, and statements, q/Q - questions, t - terms, u - unanswered, y - libraries, z/Z - statements. lowercase = current term; UPPERCASE = ALL terms."$'\n' list_op <&3
							case $list_op in 
							"a")
								list answers
								;;
							"A")
								list answers all
								;;
							"l")
								list
								;;
							"L")
								list all
								;;
							"q")
								list questions
								;;
							"Q")
								list questions all
								;;
							"t")
								list_terms
								;;
							"u")
								list_unanswered_questions
								;;
							"y")
								list_libraries
								;;
							"z")
								list statements
								;;
							"Z")
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
						"n" | "")
							break;
							;;
						"q")
							break 2
							;;
					  "r")
							read -n1 -s -p "Really restart questions from input reading? " restart_reading <&3
							if [[ $restart_reading == "y" ]]; then
								echo "$input_file" | questions_from_input
								break 2;
							fi
							;;
						"w"|"W")
							questions=()
							index=0
							while read question; do
								if [[ "$input" == "W" ]]; then
									grep -q "$question" "Terms/$current_term/answers" && continue
								fi
								questions+=("$question");
								echo "$index - $question"
								(( index++ ))
							done <"Terms/$current_term/questions"
							if [[ ${#questions} -gt 0 ]]; then
								read -p "please choose which of the above questions you would like to answer: " q_ind <&3
								if [[ ! "$q_ind" =~ [a-zA-Z] ]] && [[ -n ${questions[$q_ind]} ]]; then
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
						"y")
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
						*)
							echo "Sorry, \"$input\" command not recognized."
							sleep 0.5
							;;
					esac
				done
			fi
			line_number=$(($line_number + 1))
		done
	else
		echo "You have not yet defined a current term. Please do so with change_term, then try again."
	fi
}

questions_from_research() {
	cat research.txt | questions_from_input "$1"
}

questions_from_statements() {
	[[ -f "Terms/$current_term/statements" ]] && cat "Terms/$current_term/statements" | questions_from_input "$1"
}

statements_from_answers() {
  empty_file "Terms/$current_term/statements"
  while read line; do
		echo "$(get_statement_from_answer "$line")." >>"Terms/$current_term/statements"
  done <"Terms/$current_term/answers"
  list statements
}

get_statement_from_answer() {
	should_print="true"
	if [[ -n "$1" ]]; then
		line="$1"
	else
		read line
	fi
	sed_option=""
	if [[ $line =~ "What is" ]] && [[ $line =~ "for" ]]; then
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
	elif [[ $line =~ "What does" ]] && [[ $line =~ "mean" ]]; then
		sed_command='s/What does \(.*\) mean\? \(.*\)/\1 means \2/'
	elif [[ $line =~ "What happens" ]]; then
		sed_command='s/What happens \(.*\)\? \(.*\)/\1, \2/'
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
	elif [[ $line =~ "Why should I" ]]; then
		sed_command='s/Why should I \(.*\)\? \(.*\)/I should \1 because \2/'
	elif [[ $line =~ "Why might" ]]; then
		sed_option="-r"
		sed_command='s/Why might ([^ ]+) (.*)\? (.*)/\1 might \2 because \3/'
	elif [[ $line =~ "Under what circumstances does" ]]; then
		sed_option="-r"
		sed_command='s/Under what circumstances does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 if \4/'
	elif [[ $line =~ "How do" ]]; then
		sed_command='s/How do \(.*\)\? \(.*\)/\1 by \2/'
	elif [[ $line =~ "Is it true that" ]]; then
		sed_option="-r"
		echo "$line" | grep -qi "no," && sed_command='s/Is it true that (.*)\? ([^ ]+), (.*)/It is not true that \1 because \3/' || sed_command='s/Is it true that (.*)\? ([^ ]+). (.*)/It is true that \1 because \3/'
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
	if [[ "$1" == "questions" ]] || [[ "$1" == "answers" ]] || [[ "$1" == "statements" ]]; then
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
			echo "$1" >>"Terms/$current_term/questions" && echo "question was added to $current_term questions" || echo "ERROR: question was not added to $current_term questions."
		else
			echo "Invalid question format."
		fi
	else
		echo "You have not yet defined a current term. Please do so with change_term, then try again."
	fi
}

list_unanswered_questions() {
	if [[ -n $current_term ]]; then
		unanswered_questions=""
		while read question; do
			if [[ "$(grep "$question" "Terms/$current_term/answers")"	== "" ]]; then
				unanswered_questions+="$question\n"
			fi
		done <"Terms/$current_term/questions"
		unanswered_questions="${unanswered_questions%'\n'}"
		number_of_unanswered_questions="$(echo -e $unanswered_questions | wc -l | sed 's/^[[:space:]]*//')"
		echo -e "<-- $number_of_unanswered_questions unanswered questions about $current_term -->"
		echo -e "$unanswered_questions"
	else
		echo "You have not yet defined a current term. Please do so with change_term, then try again."
	fi
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
	rm -r "Terms/$1"
	echo "removed term $1"
	if [[ $current_term == "$1" ]]; then
		current_term="termless"
	fi
	update_qdd_prompt
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
			current_term="termless"
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
	RED='\033[30;31m'
	GREEN='\033[30;32m'
	MAGENTA='\033[30;35m'
	NC='\033[0m'
	if [[ -n $current_term ]]; then
		current_term_in_prompt="$current_term"
	else
		current_term_in_prompt="termless"
	fi
	PS1="${RED}\W ${GREEN}${current_term_in_prompt}${MAGENTA} ? ${NC}"
}

vim_research() {
	vi research.txt
}

alias qfi='questions_from_input'
alias qfr='questions_from_research'
alias qfs='questions_from_statements'
alias sfa='statements_from_answers'

alias aq='add_question'
alias lq='list questions'
alias luq='list_unanswered_questions'
alias lqa='list questions all'
alias vq='vim_questions_current_term'

alias aa='add_answer'
alias la='list answers'
alias laa='list answers all'
alias va='vim_answers_current_term'

alias gsfa='get_statement_from_answer'
alias lz='list statements'
alias lza='list statements all'
alias vz='vim_statements_current_term'

alias ct='change_term'
alias lt='list_terms'
alias mt='move_term'
alias rt='remove_term'

alias cy='change_library'
alias ly='list_libraries'
alias ry='remove_library'

alias qdd='source_qdd'
alias vr='vim_research'

update_qdd_prompt
