import React from "react";
import { Button, Menu, MenuItem, ListItemText } from "@mui/material";
import DownloadIcon from "@mui/icons-material/Download";
import { exportRows } from "../utils/exportRows";   // adjust path if needed

export default function ExportButton({ rows }) {
  const [anchorEl, setAnchorEl] = React.useState(null);
  const open = Boolean(anchorEl);

  const handleClick = (e) => setAnchorEl(e.currentTarget);
  const handleClose = () => setAnchorEl(null);

  const handleExport = (fmt) => {
    exportRows(rows, fmt);
    handleClose();
  };

  return (
    <>
      <Button
        onClick={handleClick}
        variant="contained"
        size="small"
        startIcon={<DownloadIcon />}
      >
        Download
      </Button>

      <Menu anchorEl={anchorEl} open={open} onClose={handleClose}>
        <MenuItem onClick={() => handleExport("csv")}>
          <ListItemText>CSV</ListItemText>
        </MenuItem>
        <MenuItem onClick={() => handleExport("xlsx")}>
          <ListItemText>XLSX</ListItemText>
        </MenuItem>
      </Menu>
    </>
  );
}
