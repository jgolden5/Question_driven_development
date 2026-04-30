package api

import (
  "encoding/json"
  "net/http"
  "strconv"

  "qdd/internal/model"
)

func (s *Server) LibrariesHandler(w http.ResponseWriter, r *http.Request) {
  if r.Method == http.MethodPost {
    var req model.Library
    json.NewDecoder(r.Body).Decode(&req)

    lib, err := s.LibService.CreateLibrary(req.Name)
    if err != nil {
      http.Error(w, err.Error(), 500)
      return
    }

    json.NewEncoder(w).Encode(lib)
  }
}

func (s *Server) LibraryHandler(w http.ResponseWriter, r *http.Request) {
  idStr := r.URL.Query().Get("id")
  id, _ := strconv.Atoi(idStr)

  lib, err := s.LibService.GetLibrary(id)
  if err != nil {
    http.Error(w, err.Error(), 404)
    return
  }

  json.NewEncoder(w).Encode(lib)
}
