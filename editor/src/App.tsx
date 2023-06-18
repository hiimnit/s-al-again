import { editor } from "monaco-editor";
import { useCallback, useEffect, useRef, useState } from "react";

import Editor from "@monaco-editor/react";

import registerLanguage from "./al/al";
import ConsoleManager, { ConsoleLine } from "./ConsoleManager";
import EditorManager from "./EditorManager";

function App() {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);
  const [language, setLanguage] = useState("");

  const setValue = useCallback((value: string) => {
    editorRef.current?.setValue(value);
  }, []);

  useEffect(() => {
    return EditorManager.instance.subscribe(setValue);
  }, [setValue]);

  const tokenize = () => {
    if (window.Microsoft === undefined || editorRef.current === null) {
      return;
    }

    window.Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Tokenize", [
      editorRef.current.getValue(),
    ]);
  };

  const parse = () => {
    if (window.Microsoft === undefined || editorRef.current === null) {
      return;
    }

    window.Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Parse", [
      editorRef.current.getValue(),
    ]);
  };

  const clearConsole = () => {
    ConsoleManager.instance.clear();
  };

  return (
    <div className="flex h-screen max-h-screen w-full flex-col">
      <div className="mb-1 flex flex-row border-b">
        <button
          className="my-0.5 px-6 py-2 font-bc text-bc-small font-normal transition-colors hover:bg-bc-100"
          onClick={tokenize}
        >
          Tokenize
        </button>
        <button
          className="my-0.5 px-6 py-2 font-bc text-bc-small font-normal transition-colors hover:bg-bc-100"
          onClick={parse}
        >
          Parse
        </button>
        <div className="flex-grow" />
        <button
          className="my-0.5 px-6 py-2 font-bc text-bc-small font-normal transition-colors hover:bg-bc-100"
          onClick={clearConsole}
        >
          Clear
        </button>
      </div>
      <div className="flex-1 overflow-y-auto">
        <div className="grid h-full grid-cols-1 grid-rows-2 gap-1 md:grid-cols-2 md:grid-rows-1">
          <Editor
            language={language}
            onMount={(editor, monaco) => {
              registerLanguage(monaco);
              setLanguage("al"); // hack to refresh model handled by Editor

              editorRef.current = editor;

              if (window.Microsoft !== undefined) {
                window.Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
                  "EditorReady",
                  []
                );
              }
            }}
          />
          <Console />
        </div>
      </div>
    </div>
  );
}

function Console() {
  const [lines, setLines] = useState<ConsoleLine[]>([]);
  const consoleRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    return ConsoleManager.instance.subscribe(setLines);
  }, []);

  useEffect(() => {
    consoleRef.current?.scroll({
      top: consoleRef.current.scrollHeight,
    });
  }, [consoleRef, lines]);

  return (
    <div
      ref={consoleRef}
      className="overflow-y-auto bg-gray-50 px-2 font-monaco text-xs"
    >
      {lines.map((e) => (
        <div
          key={e.entryNo}
          className="min-h-[1rem] whitespace-pre-wrap break-all"
        >
          {e.content}
        </div>
      ))}
    </div>
  );
}

export default App;
