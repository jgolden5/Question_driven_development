#!/bin/bash
#All functions and aliases relevant to question_driven_development project

exec 3<&0
current_term="$current_term"

questions_from_research() {
	if [[ -n $current_term ]]; then
		line_number=1
		research=$(cat research.txt)
		file_length="$(echo $research | sentencify | wc -l)"
		echo $sentences | sentencify | while IFS= read -r line; do
			if [[ $line == "" ]] || [[ $line == " " ]]; then
				continue
			else
				while : ; do
					WHITE='\033[30;107m'
					RED='\033[30;101m'
					GREEN='\033[30;102m'
					BLUE='\033[30;104m'
					NC='\033[0m'
					percent="$(perl -e "print int($line_number / $file_length * 100 + 0.5)")"
					printf "\033c"
					echo $line
					echo -ne "${WHITE}line $line_number ${RED} ${percent}% ${GREEN} ${current_term} ${BLUE} ❓ ${NC} => a = add question, q = quit, r = restart, any other key = next sentence"$'\n'
					read -n1 -r -s input <&3
					case $input in
						"a")
							read -p "Enter question here: " question <&3
							add_question "$question"
							sleep 1
							;;
						"q")
							break 2
							;;
					  "r")
							read -p "Really restart questions from research reading? " restart_reading <&3
							if [[ $restart_reading =~ "y" ]]; then
								echo "$sentences" | questions_from_research
								break 2;
							fi
							;;
						*)
							break;
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

answers_from_questions() {
	if [[ -n $current_term ]]; then
		question_number=1
		file_length="$(cat "Terms/$current_term/questions" | wc -l)"
		if [[ "$1" == "-u" ]]; then
			unanswered_only="true"
		else
			unanswered_only="false"
		fi
		cat "Terms/$current_term/questions" | while IFS= read -r question; do
			if [[ $question == "" ]] || [[ $question == " " ]]; then
				continue
			fi
			while : ; do
				WHITE='\033[30;107m'
				RED='\033[30;101m'
				GREEN='\033[30;102m'
				YELLOW='\033[30;103m'
				BLUE='\033[30;104m'
				NC='\033[0m'
				percent="$(perl -e "print int($question_number / $file_length * 100 + 0.5)")"
				printf "\033c"
				if [[ "$1" == "-u" ]]; then
					grep -q "$question" "Terms/$current_term/answers" && break
					echo -e "${YELLOW}UNANSWERED${NC}" && echo $question
				else
					echo "$question"
				fi
				echo -ne "${WHITE}question $question_number ${RED} ${percent}% ${GREEN} ${current_term} ${BLUE} ⁉️ ${NC} => a = answer question, q = quit, r = restart, any other key = next question"$'\n'
				read -n1 -r -s input <&3
				case $input in
					"a")
						read -p "Answer question here: " answer <&3
						add_answer "$question" "$answer" 
						sleep 1
						;;
					"q")
						break 2
						;;
					"r")
						read -p "Really restart answers from questions reading? " restart_reading <&3
						if [[ $restart_reading =~ "y" ]]; then
							echo "$questions" | answers_from_questions
							break 2;
						fi
						;;
					*)
						break;
						;;
				esac
			done
			question_number=$(($question_number + 1))
		done
	else
		echo "You have not yet defined a current term. Please do so with change_term, then try again."
	fi
}

statements_from_answers() {
	#What is = sed 's/What is \(.*\)\? \(.*\)/\1 is \2./'
	#What are = sed 's/What are \(.*\)\? \(.*\)/\1 are \2./'
	#What am = sed 's/What am \(.*\)\? \(.*\)/\1 am \2./'
	
	#Why is = sed 's/Why is \(.*\) \(.*\)\? \(.*\)/\1 is \2 because \3./'
	#Why are = sed 's/Why are \(.*\) \(.*\)\? \(.*\)/\1 are \2 because \3./'
	#Why am = sed 's/Why am \(.*\) \(.*\)\? \(.*\)/\1 am \2 because \3./'
	#Why does = sed -r 's/Why does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 because \4./'
	#Why _ I = sed 's/Why \(.*\) I \(.*\)\? \(.*\)/I \1 \2 because \3./'

	#How is = sed 's/How is \(.*\) so \(.*\)?

	line="$1"
	if [[ $line =~ "What is" ]]; then
		
	elif
	fi
}

add_answer() { #$1 = question, $2 = answer
	if [[ -n $current_term ]]; then
		if [[ "$1" =~ "?" ]] && [[ "$2" != "" ]]; then
			echo "$1 $2" >>"Terms/$current_term/answers" && echo "answer was added to $current_term answers" || echo "ERROR: question was not added to $current_term answers."
		else
			echo "question and/or answer was invalid"
		fi
	else
		echo "You have not yet defined a current term. Please do so with change_term, then try again."
	fi
}

list_answers() {
	if [[ -n $current_term ]]; then
		number_of_answers="$(cat "Terms/$current_term/answers" | cat | wc -l | sed 's/.*\([0-9]\)/\1/')"
		echo "<-- $number_of_answers answers about $current_term -->"
		cat "Terms/$current_term/answers"
	else
		echo "You have not yet defined a current term. Please do so with change_term, then try again."
	fi
}

vim_answers_from_current_term() {
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

list_questions() {
	if [[ -n $current_term ]]; then
		number_of_questions="$(cat "Terms/$current_term/questions" | cat | wc -l | sed 's/.*\([0-9]\)/\1/')"
		echo "<-- $number_of_questions questions about $current_term -->"
		cat "Terms/$current_term/questions"
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

change_term() { #set current term to $1
	if [[ -n "$1" ]]; then
		if [[ ! -d "Terms/$1" ]]; then
			mkdir "Terms/$1"
			touch "Terms/$1/answers" "Terms/$1/questions" "Terms/$1/statements"
			echo "Added directory $1 to Terms, with answers, questions, and statements files. View a list of all terms with list_terms or lt"
		fi
		current_term="$1"
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

remove_term() {
	rm -r "Terms/$1"
	echo "removed term $1"
	if [[ $current_term == "$1" ]]; then
		current_term="termless"
	fi
	update_qdd_prompt
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

alias qfr='questions_from_research'
alias afq='answers_from_questions'
alias sfa='statements_from_answers'

alias aq='add_question'
alias lq='list_questions'
alias vq='vim_questions_current_term'

alias aa='add_answer'
alias la='list_answers'
alias va='vim_answers_from_current_term'

alias ct='change_term'
alias lt='list_terms'
alias rt='remove_term'

alias qdd='source_qdd'

update_qdd_prompt
