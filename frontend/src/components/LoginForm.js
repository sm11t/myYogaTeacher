// super-temporary, do NOT ship to prod
import { MOCK_USERS } from "../mockUsers";
import { useState } from "react";

export default function LoginForm({ onLogin }) {
  const [username, setU] = useState("");
  const [password, setP] = useState("");

  const handle = () => {
    const user = MOCK_USERS.find(
      u => u.username === username && u.password === password
    );
    if (user) onLogin(user);
    else alert("Wrong credentials");
  };

  return (
    <div style={{ marginTop: 40 }}>
      <h2>Teacher login</h2>
      <input value={username} onChange={e => setU(e.target.value)} placeholder="user" />
      <input value={password} onChange={e => setP(e.target.value)} type="password" />
      <button onClick={handle}>Login</button>
    </div>
  );
}
