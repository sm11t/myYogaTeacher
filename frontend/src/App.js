// src/App.js

import { useState } from "react";
import axios from "axios";
import QueryForm from "./QueryForm";
import ResultView from "./ResultView";

function App() {
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const runQuery = (text) => {
    setError(null);
    setResult(null);
    axios
      .post("http://localhost:8000/query", { text })
      .then((res) => setResult(res.data))
      .catch((err) => {
        console.error(err);
        setError(err.response?.data?.detail || "An error occurred");
      });
  };

  return (
    <div style={{ padding: 20 }}>
      <h1>Voice-Driven Reports</h1>

      <QueryForm onSubmit={runQuery} />

      {error && (
        <div style={{ color: "red", marginBottom: 20 }}>
          Error: {error}
        </div>
      )}

      {!result && !error && (
        <p>Enter a query above (e.g. “show me student credits 10”).</p>
      )}

      {result && <ResultView data={result} />}
    </div>
  );
}

export default App;
