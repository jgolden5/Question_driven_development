package api

import (
  "log"
  "net/http"

  "qdd/internal/service"
)

type Server struct {
  LibService *service.LibraryService
}

func NewServer(libService *service.LibraryService) *Server {
  return &Server{LibService: libService}
}

func (s *Server) Start() {
  http.HandleFunc("/libraries", s.LibrariesHandler)
  http.HandleFunc("/library", s.LibraryHandler)

  log.Println("Server running on :8080")
  log.Fatal(http.ListenAndServe(":8080", nil))
}
