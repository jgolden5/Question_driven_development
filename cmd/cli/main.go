package main

import (
  "fmt"
  "os"
)

func main() {
  fmt.Println("Hello, CLI!")
  
  program := os.Args[0]
  args := os.Args[1:]
  
  fmt.Println("Program name:", program)

  if len(args) > 3 {
    fmt.Println("Too many arguments were given. Please try again and enter only 1-3 args")
  } else if len(args) < 1 {
    fmt.Println("Not enough arguments were given. Please try again and enter at least 1-3 args")
  } else {
    fmt.Println("Here are the args you entered", args)
  }
}
