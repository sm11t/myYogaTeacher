import { useEffect, useState } from "react";
import axios from "axios";

function App() {
  const [schema, setSchema] = useState(null);

  useEffect(() => {
    axios.get("http://localhost:8000/schema")   // call the backend directly
      .then(res => setSchema(res.data))
      .catch(console.error);
  }, []);
    

  if (!schema) return <div>Loading schema…</div>;

  return (
    <div style={{ padding: 20 }}>
      <h1>Database Schema</h1>
      <pre>{JSON.stringify(schema, null, 2)}</pre>
    </div>
  );
}

export default App;
