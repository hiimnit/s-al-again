import { editor } from "monaco-editor";
import { useRef } from "react";

import Editor from "@monaco-editor/react";

function App() {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);

  const tokenize = () => {
    // @ts-ignore
    if (window.Microsoft === undefined || editorRef.current === null) {
      return;
    }

    // @ts-ignore
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Tokenize", [
      editorRef.current.getValue(),
    ]);
  };

  const parse = () => {
    // @ts-ignore
    if (window.Microsoft === undefined || editorRef.current === null) {
      return;
    }

    // @ts-ignore
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Parse", [
      editorRef.current.getValue(),
    ]);
  };

  return (
    <div className="flex h-screen w-full flex-col">
      <div className="mb-1 flex flex-row border-b">
        <button
          className="px-6 py-2 text-sm transition-colors hover:bg-cyan-100"
          onClick={tokenize}
        >
          Tokenize
        </button>
        <button
          className="px-6 py-2 text-sm transition-colors hover:bg-cyan-100"
          onClick={parse}
        >
          Parse
        </button>
      </div>
      <div className="grid h-full grid-cols-1 grid-rows-2 md:grid-cols-2 md:grid-rows-1">
        <div>
          <Editor
            language="al"
            onMount={(editor) => {
              editorRef.current = editor;
            }}
          />
        </div>
        <Console />
      </div>
    </div>
  );
}

function Console() {
  // // @ts-ignore
  // window.testFunction = (test: string) => {
  //   setText(test);
  // };

  return (
    <div className="font-mono text-sm">
      <div></div>
    </div>
  );
}

// class ConsoleManager {
//   static instance = new ConsoleManager();

//   register(callback: () => void) {

//   }
// }

export default App;
