import "./index.css";

import React from "react";
import ReactDOM from "react-dom/client";

import App, { ConsoleManager } from "./App.tsx";

declare global {
  interface Window {
    WriteLine: (input: string) => void;
  }
}

ReactDOM.createRoot(
  document.getElementById("controlAddIn") as HTMLElement
).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

if (window.Microsoft !== undefined) {
  window.Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready", []);
}

// TODO buffering messages in BC is probably better
export const writeLine = (input: string) => {
  ConsoleManager.instance.writeLine(input);
};

window.WriteLine = writeLine;
