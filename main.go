package main

import (
  "qdd/internal/api"
  "qdd/internal/db"
  "qdd/internal/service"
)

func main() {
  database := db.NewDB("postgres://jgolden1:password@localhost:5432/qdd?sslmode=disable")

  libService := service.NewLibraryService(database)
  server := api.NewServer(libService)

  server.Start()
}
