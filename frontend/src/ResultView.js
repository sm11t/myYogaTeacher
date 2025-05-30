export default function ResultView({ data }) {
  const { sql, results } = data;

  if (results.length === 0) {
    return (
      <div>
        <p><em>No results found.</em></p>
        <pre>{sql}</pre>
      </div>
    );
  }

  // Table headers from the first row’s keys
  const headers = Object.keys(results[0]);

  return (
    <div>
      <h2>Generated SQL</h2>
      <pre style={{ background: "#f3f3f3", padding: 10 }}>{sql}</pre>

      <h2>Results</h2>
      <table style={{ borderCollapse: "collapse", width: "100%" }}>
        <thead>
          <tr>
            {headers.map(h => (
              <th key={h} style={{ border: "1px solid #ddd", padding: 8 }}>
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {results.map((row, i) => (
            <tr key={i}>
              {headers.map(h => (
                <td key={h} style={{ border: "1px solid #ddd", padding: 8 }}>
                  {row[h]?.toString()}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
