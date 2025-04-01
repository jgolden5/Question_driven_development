# Question_driven_development Version 8 Protcol (8P)

## 8 Rules:
1. Every complete library must have 8 complete terms—no more, no less
2. Every complete term must have 8 complete questions—no more, no less (note that there is no rule against using AI to generate _questions_ simply as a place to start)
3. Every complete question may only have 1 final answer (if there are more or less, the question is incomplete)
4. Any of these rules may be changed at any time, but just like the questions and terms, there may not be any more (or less) than 8 at any one time. So if I want to add one rule, I must remove another, and if I want to remove one rule, I must replace it with another. Thus we allow our 8 rules to be dynamic when improvements present themselves, while also remaining static in practice
5. Questions in QDD should only be asked with the intention of A) solving the problem at hand, or B) clarifying concepts relevant to the problem/topic at hand in order to reduce the number of future problems, and regardless they must be C) 8 words long or less
6. Answers in QDD must be A) my own words having passed through my own brain, B) helpful information, and C) 8 sentences or less, where each sentence is 8 words or less
7. I am encouraged to add questions and answers to my terms often, and even add new terms to my libraries, if that which I am adding is more valuable than that which I am replacing. This is the vision which empowers 8P—the idea that my quality of information and understanding can constantly increase while keeping my resulting knowledge base simple, relevant, and easy to navigate and improve
8. It is wise to use version control with QDD 8P in case I decide I prefer a recently deleted item (question, answer, term, or rule)

_See https://github.com/jgolden5/8_Protocol for more info_


# Functions (Note, in conjecture with version 8P, there are only 8 sub-functions inside of qdd's main qfi function)
__Start purely in command line and then go from there__
1. a - ask question
2. w - answer question
3. e - ?
4. r - ?
5. t - ?
6. y - ?
7. q - ?
8. define 8 keys for positions that can be used in each of the above
  - *note* any actual text will be passed in without additional key parameter
  - `<` is first
  - `>` is last
  - `,` is previous
  - `.` is next
  - `'` list
  - `=` is manual index switch
  - `-` remove
  - `?` means get help

## ask example (a)
`Tue Apr 01 09:34 jgolden1 question_driven_development [main] $ a`

`Tue Apr 01 09:35 QDD network:http [9] (ASK): What is http used for?`

>1 What is http? 
  A set of rules that defines browser communication

>2 What is the point of https? 
  Privacy, message integrity, and security through encryption

>3 How does dns convert url to ip address? 
  >>1) Check the local cache. 
  >>2) Ask the internet service provider (isp) cache. 
  >>3) Root name server checks tld used. 
  >>4) TLD name server finds resource by tld. 
  >>5) hostname server checks for resource by hostname. 
  >>6) IP address gets located or doesn't exist.

>4 What is SSL?

>5 How does HTTP do caching?

>6 What do the HTTP response codes mean (generally)?

>7 How does HTTP differ from WebSockets?

>8 What is the difference between GET and POST?
  GET is used for fetching, NOT changing state.
  GET shows up in browser history.
  Do NOT use GET with private/sensitive data.
  POST is used for changing state.

>9 What is http used for? *

`Choose a question to replace: 9`

`This will move question 9 [and any answers it may have] forever (unless you use version control), are you sure you want to do it? y`

>Ok, question 9 was removed

`Tue Apr 01 09:35 jgolden1 question_driven_development [main] $`

## answer example (w)
`Tue Apr 01 10:39 jgolden1 question_driven_development [main] $ w`

`Tue Apr 01 10:39 QDD network:http [8] {What is the difference between GET and POST?} (ANSWER): =`

`Which index? '`

>1 What is http? 
  >>A set of rules that defines browser communication

>2 What is the point of https? 
  >>Privacy, message integrity, and security through encryption

>3 How does dns convert url to ip address? 
  >>1) Check the local cache. 
  >>2) Ask the internet service provider (isp) cache. 
  >>3) Root name server checks tld used. 
  >>4) TLD name server finds resource by tld. 
  >>5) hostname server checks for resource by hostname. 
  >>6) IP address gets located or doesn't exist.

>4 What is SSL?

>5 How does HTTP do caching?

>6 What do the HTTP response codes mean (generally)?

>7 How does HTTP differ from WebSockets?

>8 What is the difference between GET and POST? *
  GET is used for fetching, NOT changing state.
  GET shows up in browser history.
  Do NOT use GET with private/sensitive data.
  POST is used for changing state.

`Which index? 4`

`Tue Apr 01 10:54 QDD network:http [4] {What is SSL?} (ANSWER): a protocol used to securely encrypt web communications`

`Answer added.`

>What is SSL?
  >>a security protocol used to encrypt web communications

`Tue Apr 01 10:58 jgolden1 question_driven_development [main] $`
