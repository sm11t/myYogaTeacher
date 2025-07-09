// src/ResultView.js
import React from "react";
import { DataGrid } from "@mui/x-data-grid";
import { Box, Typography, Stack } from "@mui/material";
import ExportButton from "./components/ExportButton";      // adjust if path differs
import "./styles/result.css";                              // status-colour helpers

export default function ResultView({ data }) {
  const { sql, results } = data || {};

  /* --------------------------------------------------------
   * Normalise: null → [] so .length and .map are always safe
   * ------------------------------------------------------ */
  const safeRows = Array.isArray(results) ? results : [];

  /* ---------- zero-row view ---------- */
  if (!safeRows.length) {
    return (
      <Box mt={2}>
        <Typography variant="body2" color="text.secondary" gutterBottom>
          <em>No results found.</em>
        </Typography>
        {sql && (
          <pre style={{ background: "#f3f3f3", padding: 10, overflowX: "auto" }}>
            {sql}
          </pre>
        )}
      </Box>
    );
  }

  /* ---------- build DataGrid rows / columns ---------- */
  const headers = Object.keys(safeRows[0]);
  const columns = headers.map((h) => ({
    field: h,
    headerName: h.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()),
    flex: 1,
  }));

  // DataGrid requires a unique id for each row
  const rows = safeRows.map((r, idx) => ({ id: idx, ...r }));

  return (
    <Box mt={2}>
      {/* -------- generated SQL -------- */}
      <Typography variant="h6" gutterBottom>
        Generated SQL
      </Typography>
      <pre style={{ background: "#f3f3f3", padding: 10, overflowX: "auto" }}>
        {sql}
      </pre>

      {/* -------- results header & export -------- */}
      <Stack
        direction="row"
        justifyContent="space-between"
        alignItems="center"
        mt={4}
        mb={1}
      >
        <Typography variant="h6">Results&nbsp;({rows.length})</Typography>
        <ExportButton rows={safeRows} /> {/* CSV & XLSX download */}
      </Stack>

      {/* -------- pretty grid -------- */}
      <DataGrid
        autoHeight
        rows={rows}
        columns={columns}
        pageSize={10}
        rowsPerPageOptions={[10, 25, 50]}
        disableSelectionOnClick
        getRowClassName={(params) => {
          const status = params.row.status?.toUpperCase?.();
          if (status === "SCHEDULED") return "status-scheduled";
          if (status === "COMPLETED") return "status-completed";
          return "";
        }}
        sx={{
          "& .MuiDataGrid-columnHeaders": { backgroundColor: "#fafafa" },
          "& .MuiDataGrid-cell": { outline: "none !important" },
        }}
      />
    </Box>
  );
}
