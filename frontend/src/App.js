// src/App.js
import { useState } from "react";
import axios from "axios";

import QueryForm   from "./QueryForm";
import ResultView  from "./ResultView";
import LoginForm   from "./components/LoginForm";      // ⬅ new
// (mockUsers.ts is only imported by LoginForm)

function App() {
  /* ---------- auth state ---------- */
  const [me, setMe] = useState(() => {
    try { return JSON.parse(localStorage.getItem("me")) || null; }
    catch { return null; }
  });

  const handleLogin = (user) => {
    setMe(user);
    localStorage.setItem("me", JSON.stringify(user));
  };

  const logout = () => {
    setMe(null);
    localStorage.removeItem("me");
  };

  /* ---------- query state ---------- */
  const [result, setResult] = useState(null);
  const [error,  setError]  = useState(null);

  const runQuery = (text) => {
    if (!me) return;                       // should never happen
    setError(null);
    setResult(null);

    axios.post("/query",                  // use proxy → Go → Python
      { text, teacherId: me.teacherId })  // ⬅ scope every query
      .then(res => setResult(res.data))
      .catch(err => {
        console.error(err);
        setError(err.response?.data?.detail || "An error occurred");
      });
  };

  /* ---------- render ---------- */
  if (!me) return <LoginForm onLogin={handleLogin} />;

  return (
    <div style={{ padding: 20 }}>
      <div style={{ marginBottom: 10 }}>
        Logged in as: <strong>{me.username}</strong>
        <button onClick={logout} style={{ marginLeft: 12 }}>Logout</button>
      </div>

      <h1>Voice-Driven Reports</h1>

      <QueryForm onSubmit={runQuery} />

      {error  && <div style={{ color: "red", marginBottom: 20 }}>Error: {error}</div>}
      {!result && !error && (
        <p>Enter a query above (e.g. “show me my students whose trial is expiring tomorrow”).</p>
      )}
      {result && <ResultView data={result} />}
    </div>
  );
}

export default App;
