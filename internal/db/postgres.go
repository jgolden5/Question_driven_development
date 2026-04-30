package db

import (
  "database/sql"
  "log"

  _ "github.com/lib/pq" //postgres driver making Postgres requests understandable by Go code
)

type DB struct {
  Conn *sql.DB
}

func NewDB(connStr string) *DB {
  conn, err := sql.Open("postgres", connStr)
  if err != nil {
    log.Fatal(err)
  }

  if err = conn.Ping(); err != nil {
    log.Fatal(err)
  }

  return &DB{Conn: conn}
}

func (db *DB) CreateLibrary(name string) (int, error) {
  var id int
  err := db.Conn.QueryRow(
    "INSERT INTO libraries (name) VALUES ($1) RETURNING id",
    name,
  ).Scan(&id)

  return id, err
}

func (db *DB) GetLibrary(id int) (string, error) {
  var name string
  err := db.Conn.QueryRow(
    "SELECT name FROM libraries WHERE id=$1",
    id,
  ).Scan(&name)

  return name, err
}
