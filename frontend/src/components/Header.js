import React from "react";
import "./Header.css";
import logo from "../assets/logo.svg";

export default function Header({ user, onLogout }) {
  return (
    <header className="header">
      <img src={logo} alt="MyYogaTeacher" className="header-logo" />

      <div className="header-user">
        Logged in as <strong>{user.username}</strong>
        <button className="logout-button" onClick={onLogout}>
          Logout
        </button>
      </div>
    </header>
  );
}
