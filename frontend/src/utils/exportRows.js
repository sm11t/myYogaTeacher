import { utils, writeFile } from 'xlsx';
import Papa from 'papaparse';

export function exportRows(rows, type = 'csv') {
  if (type === 'xlsx') {
    const ws   = utils.json_to_sheet(rows);
    const wb   = utils.book_new();
    utils.book_append_sheet(wb, ws, 'Report');
    writeFile(wb, 'report.xlsx');
  } else {
    const csv  = Papa.unparse(rows);
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url  = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href  = url;
    link.setAttribute('download', 'report.csv');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
}
