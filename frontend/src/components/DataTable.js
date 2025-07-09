import { DataGrid } from '@mui/x-data-grid';

export default function DataTable({ rows }) {
  const columns = [
    { field: 'start_time', headerName: 'Time', flex: 1 },
    { field: 'student',    headerName: 'Student', flex: 1 },
    { field: 'location',   headerName: 'Location', flex: 1 },
    { field: 'status',     headerName: 'Status', flex: 1 },
  ];

  return (
    <DataGrid
      rows={rows}
      columns={columns}
      autoHeight
      getRowId={(r) => r.id}
      getRowClassName={({ row }) =>
        row.status === 'SCHEDULED' ? 'status-scheduled' : 'status-completed'
      }
    />
  );
}
