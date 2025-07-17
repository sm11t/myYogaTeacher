// src/components/ColumnSelector.js
import React from "react";

export default function ColumnSelector({ allColumns, visibleCols, onChange }) {
  const toggle = colKey =>
    onChange(
      visibleCols.includes(colKey)
        ? visibleCols.filter(c => c !== colKey)
        : [...visibleCols, colKey]
    );

  return (
    <div style={{ marginBottom: 12 }}>
      <strong style={{ marginRight: 8 }}>Columns:</strong>
      {allColumns.map(colKey => (
        <label key={colKey} style={{ margin: "0 8px", cursor: "pointer" }}>
          <input
            type="checkbox"
            checked={visibleCols.includes(colKey)}
            onChange={() => toggle(colKey)}
          />{" "}
          {colKey}
        </label>
      ))}
    </div>
  );
}
