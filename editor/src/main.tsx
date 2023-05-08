import "./index.css";

import React from "react";
import ReactDOM from "react-dom/client";

import App from "./App.tsx";

ReactDOM.createRoot(
  document.getElementById("controlAddIn") as HTMLElement
).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

// @ts-ignore
if (window.Microsoft !== undefined) {
  // @ts-ignore
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready", []);
}
