package db

import (
    "database/sql"

    _ "github.com/lib/pq"
)

// Store wraps a sql.DB connection.
type Store struct {
    DB *sql.DB
}

// NewStore opens a Postgres connection using connStr (your DATABASE_URL).
func NewStore(connStr string) (*Store, error) {
    db, err := sql.Open("postgres", connStr)
    if err != nil {
        return nil, err
    }
    return &Store{DB: db}, nil
}

// Query runs a SQL query and returns the rows.
func (s *Store) Query(query string, args ...interface{}) (*sql.Rows, error) {
    return s.DB.Query(query, args...)
}
