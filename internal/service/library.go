package service

import (
  "qdd/internal/db"
  "qdd/internal/model"
)

type LibraryService struct {
  DB *db.DB
}

func NewLibraryService(db *db.DB) *LibraryService {
  return &LibraryService{DB: db}
}

func (s *LibraryService) CreateLibrary(name string) (model.Library, error) {
  id, err := s.DB.CreateLibrary(name)
  if err != nil {
    return model.Library{}, err
  }

  return model.Library{ID: id, Name: name}, nil
}

func (s *LibraryService) GetLibrary(id int) (model.Library, error) {
  name, err := s.DB.GetLibrary(id)
  if err != nil {
    return model.Library{}, err
  }

  return model.Library{ID: id, Name: name}, nil
}
