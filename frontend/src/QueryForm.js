import { useState } from "react";

export default function QueryForm({ onSubmit }) {
  const [text, setText] = useState("");

  const handleSubmit = e => {
    e.preventDefault();
    if (text.trim()) onSubmit(text.trim());
  };

  return (
    <form onSubmit={handleSubmit} style={{ marginBottom: 20 }}>
      <input
        type="text"
        value={text}
        onChange={e => setText(e.target.value)}
        placeholder="Type your query…"
        style={{ width: "70%", padding: 8 }}
      />
      <button type="submit" style={{ marginLeft: 8, padding: "8px 16px" }}>
        Run
      </button>
    </form>
  );
}
