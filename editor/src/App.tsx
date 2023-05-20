import { editor } from "monaco-editor";
import { useEffect, useRef, useState } from "react";

import Editor from "@monaco-editor/react";

function App() {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);

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

  return (
    <div className="flex h-screen max-h-screen w-full flex-col">
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
      <div className="flex-1 overflow-y-auto">
        <div className="grid h-full grid-cols-1 grid-rows-2 gap-1 md:grid-cols-2 md:grid-rows-1">
          <Editor
            language="al"
            onMount={(editor) => {
              editorRef.current = editor;
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
    <div ref={consoleRef} className="overflow-y-auto font-monaco text-xs">
      {lines.map((e) => (
        <div key={e.entryNo} className="whitespace-pre-wrap break-all">
          {e.content}
        </div>
      ))}
    </div>
  );
}

type ConsoleSubscriptionCallback = (lines: ConsoleLine[]) => void;
type UnsubscribeFunction = () => void;
type ConsoleLine = {
  entryNo: number;
  content: string;
};

export class ConsoleManager {
  lines: ConsoleLine[];
  subscriptions: ConsoleSubscriptionCallback[];
  counter: number;

  constructor() {
    this.lines = [];
    this.subscriptions = [];
    this.counter = 0;
  }

  static instance = new ConsoleManager();

  subscribe(callback: ConsoleSubscriptionCallback): UnsubscribeFunction {
    this.subscriptions.push(callback);

    return () => {
      this.subscriptions = this.subscriptions.filter((e) => e !== callback);
    };
  }

  writeLine(line: string) {
    this.lines.push({ entryNo: this.counter++, content: line });
    this.notify();
  }

  clear() {
    this.lines = [];
    this.notify();
  }

  notify() {
    for (const subscriber of this.subscriptions) {
      subscriber(this.lines.slice());
    }
  }
}

export default App;
