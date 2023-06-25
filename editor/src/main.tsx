import "./index.css";

import React from "react";
import ReactDOM from "react-dom/client";

import App from "./App.tsx";
import ConsoleManager from "./ConsoleManager.ts";
import EditorManager from "./EditorManager.ts";
import LSPMessenger from "./LSPMessenger.ts";

declare global {
  interface Window {
    WriteLine: (input: string) => void;
    SetEditorValue: (value: string) => void;
    ResolveSuggestionsRequest: (key: number, suggestions: string) => void;
  }
}

ReactDOM.createRoot(
  document.getElementById("controlAddIn") as HTMLElement
).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

// TODO buffering messages in BC is probably better
export const writeLine = (input: string) => {
  ConsoleManager.instance.writeLine(input);
};
window.WriteLine = writeLine;

export const setEditorValue = (value: string) => {
  EditorManager.instance.setValue(value);
};
window.SetEditorValue = setEditorValue;

export const resolveSuggestionsRequest = (key: number, suggestions: string) => {
  LSPMessenger.instance.receive(key, suggestions);
};
window.ResolveSuggestionsRequest = resolveSuggestionsRequest;

if (window.Microsoft !== undefined) {
  window.Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready", []);
}
