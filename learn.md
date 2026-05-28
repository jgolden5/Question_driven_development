# Learn.md
*Learn First, then code, then debug with grace and agility so I don't get stuck solving all my problems with a flood of AI vomit*
## Learning Strategy
1. Identify a specific concept I want to understand, let's say it's go.mod files
2. run the following: 'flip -m 1 -s 3 "go.mod files in a Golang project"'
3. click on all 3 links that chat gippity gives me, opening each in a new tab
4. study the topics in each, using QDD (bash_version) to learn about them

## file heirarchy
### cmd/cli/main.go
* entry-point which manages os args to be sent to internal/cli/cli.go to manage business logic
### internal/cli/cli.go
* business logic for CLI args
