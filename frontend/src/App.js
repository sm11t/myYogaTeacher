import React, { useState } from "react";
import axios from "axios";

import "./index.css";          // ensure global styles are loaded
import Header from "./components/Header";
import QueryForm from "./QueryForm";
import ResultView from "./ResultView";
import LoginForm from "./components/LoginForm";

function App() {
  /* ---------- auth state ---------- */
  const [me, setMe] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem("me")) || null;
    } catch {
      return null;
    }
  });

  const handleLogin = user => {
    setMe(user);
    localStorage.setItem("me", JSON.stringify(user));
  };

  const logout = () => {
    setMe(null);
    localStorage.removeItem("me");
  };

  /* ---------- query state ---------- */
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  const runQuery = payload => {
    if (!me) return;
    setError(null);
    setResult(null);

    // AUDIO path
    if (payload instanceof FormData) {
      axios
        .post("http://localhost:8000/whisper", payload, {
          headers: { "Content-Type": "multipart/form-data" }
        })
        .then(res => runQuery(res.data.transcript))
        .catch(() => setError("ASR failed"));
      return;
    }

    // TEXT path
    axios
      .post("/query", { text: payload, teacherId: me.teacherId })
      .then(res => setResult(res.data))
      .catch(err =>
        setError(err.response?.data?.detail || "An error occurred")
      );
  };

  /* ---------- render ---------- */
  if (!me) {
    return (
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          height: "100vh",
          background: "var(--bg-dark)"
        }}
      >
        <LoginForm onLogin={handleLogin} />
      </div>
    );
  }

  return (
    <div style={{ minHeight: "100vh", background: "var(--bg-dark)" }}>
      <Header user={me} onLogout={logout} />

      <main style={{ padding: 24 }}>
        <h1 style={{ color: "var(--accent)" }}>Voice-Driven Reports</h1>

        <QueryForm onSubmit={runQuery} />

        {error && (
          <div style={{ color: "#e74c3c", marginBottom: 20 }}>
            Error: {error}
          </div>
        )}

        {!result && !error && (
          <p className="text-muted">
            Enter a query above (e.g. “show me my students whose trial is
            expiring tomorrow”).
          </p>
        )}

        {result && <ResultView data={result} />}
      </main>
    </div>
  );
}

export default App;
