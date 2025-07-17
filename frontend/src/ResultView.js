// src/ResultView.js
import React, { useState, useMemo, useEffect } from "react";
import ColumnSelector from "./components/ColumnSelector";
import "./ResultView.css";

export default function ResultView({ data }) {
  // 1) Memoize results array so hooks see stable deps
  const results = useMemo(() => data?.results ?? [], [data?.results]);

  // Derive all column keys
  const allColumns = useMemo(
    () => (results.length ? Object.keys(results[0]) : []),
    [results]
  );

  // 2) Visible columns state
  const [visibleCols, setVisibleCols] = useState(allColumns);
  useEffect(() => {
    setVisibleCols(allColumns);
  }, [allColumns]);

  // 3) Sorting state
  const [sortField, setSortField] = useState(null);    // e.g. "start_time"
  const [sortDir, setSortDir]     = useState("asc");   // "asc" or "desc"

  // 4) Compute sorted & filtered rows
  const displayedRows = useMemo(() => {
    let rows = [...results];
    if (sortField) {
      rows.sort((a, b) => {
        const av = a[sortField], bv = b[sortField];
        if (av == null) return -1;
        if (bv == null) return 1;
        if (av < bv) return sortDir === "asc" ? -1 : 1;
        if (av > bv) return sortDir === "asc" ? 1 : -1;
        return 0;
      });
    }
    return rows;
  }, [results, sortField, sortDir]);

  // Early return if no data
  if (!displayedRows.length) return null;

  // Only the columns users have checked
  const columns = allColumns.filter(col => visibleCols.includes(col));

  // Header click toggles sorting
  const onHeaderClick = col => {
    if (sortField === col) {
      setSortDir(prev => (prev === "asc" ? "desc" : "asc"));
    } else {
      setSortField(col);
      setSortDir("asc");
    }
  };

  return (
    <div className="rv-container">
      <h2 className="rv-heading accent">Generated SQL</h2>
      <pre className="rv-sql">{data.sql}</pre>

      <h2 className="rv-heading accent">
        Results <span className="rv-count">({displayedRows.length})</span>
      </h2>

      <ColumnSelector
        allColumns={allColumns}
        visibleCols={visibleCols}
        onChange={setVisibleCols}
      />

      <div className="rv-table-wrapper">
        <table className="rv-table">
          <thead>
            <tr>
              {columns.map(col => (
                <th
                  key={col}
                  onClick={() => onHeaderClick(col)}
                  style={{ cursor: "pointer", userSelect: "none" }}
                >
                  {col}
                  {sortField === col
                    ? sortDir === "asc"
                      ? " 🔼"
                      : " 🔽"
                    : ""}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {displayedRows.map((row, i) => (
              <tr key={i}>
                {columns.map(col => (
                  <td key={col}>{row[col]}</td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
