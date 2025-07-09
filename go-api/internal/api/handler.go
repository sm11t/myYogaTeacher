package api

import (
	"encoding/json"
	"log"
	"net/http"

	"myyogateacher-go/internal/client"
	"myyogateacher-go/internal/db"
)

// ──────────────────────────────────────────────────────────────
// JSON we expect from the React frontend
// ──────────────────────────────────────────────────────────────
type QueryRequest struct {
	Text      string `json:"text"`
	TeacherID int    `json:"teacherId"`
}

// ──────────────────────────────────────────────────────────────
// Build the HTTP handler with all routes wired up
// ──────────────────────────────────────────────────────────────
func NewHandler(pythonURL, dbConn string) (http.Handler, error) {
	mux := http.NewServeMux()

	// ───── health check ─────
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
	})

	// shared deps
	py    := client.NewClient(pythonURL)
	store, err := db.NewStore(dbConn)
	if err != nil {
		return nil, err
	}

	// ───── POST /query ─────
	mux.HandleFunc("/query", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")

		// 1️⃣ decode body
		var req QueryRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// 2️⃣ call Python NLU → SQL
		sqlResp, err := py.ParseText(req.Text, req.TeacherID)
		if err != nil {
			log.Printf("Python service error: %v", err)
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}

		// 3️⃣ run SQL in Postgres
		rows, err := store.Query(sqlResp.SQL)
		if err != nil {
			log.Printf("DB query failed: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		// 4️⃣ scan into slice of maps
		cols, err := rows.Columns()
		if err != nil {
			log.Printf("Rows.Columns error: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		var results []map[string]interface{}
		for rows.Next() {
			vals := make([]interface{}, len(cols))
			ptrs := make([]interface{}, len(cols))
			for i := range vals {
				ptrs[i] = &vals[i]
			}
			if err := rows.Scan(ptrs...); err != nil {
				log.Printf("Rows.Scan error: %v", err)
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			row := make(map[string]interface{}, len(cols))
			for i, col := range cols {
				row[col] = vals[i]
			}
			results = append(results, row)
		}

		// 5️⃣ encode response
		if err := json.NewEncoder(w).Encode(map[string]interface{}{
			"sql":     sqlResp.SQL,
			"results": results,
		}); err != nil {
			log.Printf("JSON encode failed: %v", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	})

	return mux, nil
}
