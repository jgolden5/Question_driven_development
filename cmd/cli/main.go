package main

import (
  "bytes"
  "encoding/json"
  "fmt"
  "net/http"
  "os"
)

type Library struct {
  Name string `json:"name"`
}

func main() {
  if len(os.Args) < 3 {
    fmt.Println("Usage: create-library <name>")
    return
  }

  command := os.Args[1]

  if command == "create-library" {
    name := os.Args[2]

    lib := Library{Name: name}
    body, _ := json.Marshal(lib)

    resp, err := http.Post(
      "http://localhost:8080/libraries",
      "application/json",
      bytes.NewBuffer(body),
    )

    if err != nil {
      panic(err)
    }

    defer resp.Body.Close()

    fmt.Println("Library created:", name)
  }
}
