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
  elif [[ $line =~ "What would happen if " ]]; then
    sed_command='s/What would happen if \(.*\)\? \(.*\)/If \1, then \2/'
  elif [[ $line =~ "What makes a " ]]; then
    sed_command='s/What makes a \(.*\)\? \(.*\)/\1 is \2/'
  elif [[ $line =~ "What " ]] && [[ $line =~ " makes " ]] && [[ $line =~ " get treated " ]]; then
    sed_command='s/What \(.*\) makes \(.*\) get treated \(.*\)\? \(.*\)/The \1 that makes \2 get treated \3 is \4/'
  elif [[ $line =~ "What makes " ]]; then
    sed_command='s/What makes \(.*\)\? \(.*\)/What makes \1 is \2/'
  elif [[ $line =~ "What causes" ]]; then
    sed_command='s/What causes \(.*\)\? \(.*\)/Something that causes \1 is \2/'
  elif [[ $line =~ "What occurs in " ]]; then
    sed_command='s/What occurs in \(.*\)\? \(.*\)/In \1, what occurs is \2/'
  elif [[ $line =~ "According to " ]] && [[ $line =~ "what " ]] && [[ $line =~ is|are|am ]]; then
    sed_option="-r"
    sed_command='s/According to (.*), what ([^ ]+) (.*)\? (.*)/According to \1, \3 \2 \4/'
  elif [[ $line =~ "What is so " ]] && [[ $line =~ " about " ]]; then
    sed_command='s/What is so \(.*\) about \(.*\)\? \(.*\)/Something that is so \1 about \2 is \3/'
  elif [[ $line =~ "What difference does " ]] && [[ $line =~ " make" ]]; then
    sed_command='s/What difference does \(.*\) make\(.*\)\? \(.*\)/The difference that \1 makes\2 is \3/'
  elif [[ $line =~ "What do I need in order to " ]]; then
    sed_command='s/What do I need in order to \(.*\)\? \(.*\)/In order to \1, I need \2/'
  elif [[ $line =~ "What do " ]] && [[ $line =~ " do for " ]]; then
    sed_command='s/What do \(.*\) do for \(.*\)\? \(.*\)/What \1 do for \2 is \3/'
  elif [[ $line =~ "What does it mean to" ]]; then
    sed_command='s/What does it mean to \(.*\)\? \(.*\)/To \1 means to \2/'
  elif [[ $line =~ "What does it mean when" ]]; then
    sed_command='s/What does it mean when \(.*\)\? \(.*\)/When \1, it means that \2/'
  elif [[ $line =~ "What does it mean for" ]] && [[ $line =~ "to " ]]; then
    sed_command='s/What does it mean for \(.*\) to \(.*\)\? \(.*\)/For \1 to \2 means that \3/'
  elif [[ $line =~ "What does it mean if" ]]; then
    sed_command='s/What does it mean if \(.*\)\? \(.*\)/If \1, it means that \2/'
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
  elif [[ $line =~ "What " ]] && [[ $line =~ " does " ]] && [[ $line =~ " use?" ]]; then
    sed_command='s/What \(.*\) does \(.*\) use\? \(.*\)/The \1 that \2 uses is \3/'
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
  elif [[ $line =~ "What role can" ]] && [[ $line =~ "play in" ]]; then
    sed_command='s/What role can \(.*\) play in \(.*\)\? \(.*\)/In \2, \1 plays the role of \3/'
  elif [[ $line =~ "What role can" ]] && [[ $line =~ "play with" ]]; then
    sed_command='s/What role can \(.*\) play with \(.*\)\? \(.*\)/With \2, \1 plays the role of \3/'
  elif [[ $line =~ "What role does" ]] && [[ $line =~ "play in" ]]; then
    sed_command='s/What role does \(.*\) play in \(.*\)\? \(.*\)/In \2, \1 plays the role of \3/'
  elif [[ $line =~ "What role do " ]] && [[ $line =~ "play in" ]]; then
    sed_command='s/What role do \(.*\) play in \(.*\)\? \(.*\)/In \2, \1 play the role of \3/'
  elif [[ $line =~ "What type of" ]] && [[ $line =~ "is stored in" ]]; then
    sed_command='s/What type of \(.*\) is stored in \(.*\)\? \(.*\)/\3 is stored in \2/'
  elif [[ $line =~ "What types of" ]] && [[ $line =~ "are stored in" ]]; then
    sed_command='s/What types of \(.*\) are stored in \(.*\)\? \(.*\)/\3 \1 are stored in \2/'
  elif [[ $line =~ "What steps does " ]] && [[ $line =~ " take to " ]]; then
    sed_command='s/What steps does \(.*\) take to \(.*\)\? \(.*\)/The steps \1 takes to \2 are \3/'
  elif [[ $line =~ "What" ]] && [[ $line =~ " would " ]] && [[ $line =~ " use to " ]]; then
    sed_option="-r"
    sed_command='s/What (.*) would ([^ ]+) use to (.*)\?/\2 would use \1 to \3/'
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
  elif [[ $line =~ "What " ]] && [[ $line =~ " are " ]]; then
    sed_command='s/What \(.*\)s\(.*\) are \(.*\)\? \(.*\)/Some \1s that are \3 include \4/'
  elif [[ $line =~ "Would " ]] && [[ $line =~ " be " ]] && [[ $line =~ " if " ]]; then
    sed_command='s/Would \(.*\) be \(.*\) if \(.*\)\? \(.*\)/When \1, the \2 that \3 is \4/'
    echo "$line" | grep -qi "no," && sed_command='s/Would \(.*\) be \(.*\) if \(.*\)\? \(.*\), \(.*\)/No, \1 would NOT be \2 if \3, because \4/' || sed_command='s/Would \(.*\) be \(.*\) if \(.*\)\? \(.*\), \(.*\)/Yes, \1 WOULD be \2 if \3, because \4/'
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
  elif [[ $line =~ "When is " ]] && [[ $line =~ "ed?" ]]; then
    sed_option="-r"
    sed_command='s/When is (.*) ([^ ]+)ed\? (.*)/\1 is \2ed when \3/'
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
  elif [[ $line =~ "How much " ]] && [[ $line =~ " does " ]] && [[ $line =~ " have?" ]]; then
    sed_command='s/How much \(.*\) does \(.*\) have\? \(.*\)/The amount of \1 that \2 has is \3/'
  elif [[ $line =~ "How are" ]] && [[ $line =~ " made to " ]]; then
    sed_command='s/How are \(.*\) made to \(.*\)\? \(.*\)/\1 are made to \2 by \3/'
  elif [[ $line =~ "How does" ]] && [[ $line =~ "work?" ]]; then
    sed_command='s/How does \(.*\) work\? \(.*\)/\1 works by \2/'
  elif [[ $line =~ "How does" ]] && [[ $line =~ " work " ]] && [[ $line =~ " on " ]]; then
    sed_command='s/How does \(.*\) work on \(.*\)\? \(.*\)/\1 works on \2 by \3/'
  elif [[ $line =~ "How does" ]] && [[ $line =~ " a " ]]; then
    sed_option="-r"
    sed_command='s/How does a ([^ ]+) ([^ ]+)(.*)\? (.*)/A \1 \2s\3 by \4/'
  elif [[ $line =~ "How does" ]]; then
    sed_option="-r"
    sed_command='s/How does ([^ ]+) ([^ ]+) (.*)\? (.*)/\1 \2s \3 by \4/'
  elif [[ $line =~ "How do" ]]; then
    sed_command='s/How do \(.*\)\? \(.*\)/\1 by \2/'
  elif [[ $line =~ "How can " ]] && [[ $line =~ " be " ]]; then
    sed_command='s/How can \(.*\) be \(.*\)\? \(.*\)/\1 can be \2 by \3/'
  elif [[ $line =~ "How can" ]]; then
    sed_option="-r"
    sed_command='s/How can ([^ ]+) (.*)\? (.*)/\1 can \2 by \3/'
  elif [[ $line =~ "How is" ]] && [[ $line =~ "ed" ]]; then
    sed_command='s/How is \(.*\) \(.*\)ed\(.*\)\? \(.*\)/\1 is \2ed\3 \4/'
  elif [[ $line =~ "How is a" ]] && [[ $line =~ "ed" ]]; then
    sed_command='s/How is a \(.*\) \(.*\)ed\(.*\)\? \(.*\)/A \1 is \2ed\3 \4/'
  elif [[ $line =~ "How would I " ]]; then
    sed_command='s/How would I \(.*\)\? \(.*\)/I would \1 by \2/'
  elif [[ $line =~ "How might " ]] && [[ $line =~ " be " ]]; then
    sed_command='s/How might \(.*\) be \(.*\)\? \(.*\)/\1 might be \2 by \3/'
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
  elif [[ $line =~ "Is it " ]] && [[ $line =~ " to " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no, " && sed_command='s/Is it (.*) to (.*)\? ([^ ]+) (.*)/no, it is NOT \1 to \2, because \4/' || sed_command='s/Is it (.*) to (.*)\? ([^ ]+), (.*)/Yes, it IS \1 to \2, because \4/'
  elif [[ $line =~ "Is " ]] && [[ $line =~ " or " ]]; then
    sed_option="-r"
    sed_command='s/Is (.*) ([^ ]+) or (.*)\? (.*)/\1 is \4/'
  elif [[ $line =~ "Is " ]] && [[ $line =~ " a " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Is (.*) a (.*)\? ([^ ]+), (.*)/no, \1 is NOT a \2 because \4/' || sed_command='s/Is (.*) a (.*)\? ([^ ]+), (.*)/Yes, \1 IS a \2 because \4/'
  elif [[ $line =~ "Was " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no," && sed_command='s/Was (.*) ([^ ]+)\? ([^ ]+), (.*)/\1 was NOT \2 because \4/' || sed_command='s/Was (.*) ([^ ]+)\? ([^ ]+), (.*)/\1 WAS \2 because \4/'
  elif [[ $line =~ "How " ]] && [[ $line =~ "ould you " ]]; then
    sed_command='s/How \(.*ould\) you \(.*\)\? \(.*\)/You \1 \2 by \3/'
  elif [[ $line =~ "Does " ]] && [[ $line =~ " get " ]] && [[ $line =~ "ed for " ]] && [[ $line =~ " or " ]]; then
    sed_option="-r"
    sed_command='s/Does (.*) get ([^ ]+)ed for (.*) or (.*)\? (.*)/\1 gets \2ed for \5/'
  elif [[ $line =~ "Does" ]] && [[ $line =~ "have to" ]]; then
    echo "$line" | grep -qi "no," && sed_command='s/Does \(.*\) have to \(.*\)\? \(.*\), \(.*\)/\1 does NOT have to \2 because \4/' || sed_command='s/Does \(.*\) have to \(.*\)\? \(.*\)/\1 DOES have to \2 because \3/'
  elif [[ $line =~ "Does" ]] && [[ $line =~ " cause " ]]; then
    sed_option="-r"
    echo "$line" | grep -qi "no, " && sed_command='s/Does (.*) cause (.*)\? ([^ ]+) (.*)/No, \1 does NOT cause \2 because \4/' || sed_command='s/Does (.*) cause (.*)\? ([^ ]+) (.*)/Yes, \1 DOES cause \2 because \4/' 
  elif [[ $line =~ "Does" ]] && [[ $line =~ " only " ]]; then
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

