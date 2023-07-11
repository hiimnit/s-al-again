import "./index.css";

import React from "react";
import ReactDOM from "react-dom/client";

import { AlParsingResult, StaticSymbols } from "./al/al.ts";
import App from "./App.tsx";
import ConsoleManager from "./ConsoleManager.ts";
import EditorManager from "./EditorManager.ts";
import LSPMessenger from "./LSPMessenger.ts";

declare global {
  interface Window {
    WriteLine: (input: string) => void;
    SetEditorValue: (value: string) => void;
    SetStaticSymbols: (symbols: StaticSymbols) => void;
    ResolveSuggestionsRequest: (
      key: number,
      suggestions: AlParsingResult
    ) => void;
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

export const resolveSuggestionsRequest = (
  key: number,
  suggestions: AlParsingResult
) => {
  LSPMessenger.instance.receive(key, suggestions);
};
window.ResolveSuggestionsRequest = resolveSuggestionsRequest;

export const setStaticSymbols = (symbols: StaticSymbols) => {
  LSPMessenger.instance.staticSymbols = symbols;
};
window.SetStaticSymbols = setStaticSymbols;

if (window.Microsoft !== undefined) {
  window.Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready", []);
}
