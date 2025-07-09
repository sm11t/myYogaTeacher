package client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

// ─────────────── JSON payloads ───────────────
type NLUPayload struct {
	Text      string `json:"text"`
	TeacherID int    `json:"teacher_id"` // snake-case for Python
}

type SQLResponse struct {
	SQL     string                   `json:"sql"`
	Results []map[string]interface{} `json:"results"`
}

// ─────────────── client ───────────────
type Client struct {
	BaseURL string
	HTTP    *http.Client
}

func NewClient(pythonURL string) *Client {
	return &Client{BaseURL: pythonURL, HTTP: &http.Client{}}
}

func (c *Client) ParseText(text string, teacherID int) (*SQLResponse, error) {
	payload := NLUPayload{Text: text, TeacherID: teacherID}
	raw, _ := json.Marshal(payload)

	resp, err := c.HTTP.Post(c.BaseURL+"/query", "application/json", bytes.NewReader(raw))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("python error: %s", string(body))
	}

	var out SQLResponse
	if err := json.Unmarshal(body, &out); err != nil {
		return nil, err
	}
	return &out, nil
}
