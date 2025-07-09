package main

import (
    "log"
    "net/http"
    "os"

    "myyogateacher-go/internal/api"
)

func main() {
    pythonURL := os.Getenv("PYTHON_NLU_URL")
    if pythonURL == "" {
        pythonURL = "http://localhost:8000"
    }
    dbConn := os.Getenv("DATABASE_URL")
    if dbConn == "" {
        log.Fatal("DATABASE_URL not set")
    }

    handler, err := api.NewHandler(pythonURL, dbConn)
    if err != nil {
        log.Fatalf("failed to create handler: %v", err)
    }

    addr := ":8080"
    log.Printf("Go API listening on %s\n", addr)
    log.Fatal(http.ListenAndServe(addr, handler))
}
