// monarch language definition for al language
// created by combining pascal and csharp definitions from monaco-editor basic languages
// https://github.com/microsoft/monaco-editor/blob/main/src/basic-languages/pascal/pascal.ts
// https://github.com/microsoft/monaco-editor/blob/main/src/basic-languages/csharp/csharp.ts

import { languages } from "monaco-editor";

import { Monaco } from "@monaco-editor/react";

import LSPMessenger from "../LSPMessenger";

const conf: languages.LanguageConfiguration = {
  wordPattern:
    // eslint-disable-next-line no-useless-escape
    /(-?\d*\.\d\w*)|([^\`\~\!\#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
  comments: {
    lineComment: "//",
    blockComment: ["/*", "*/"],
  },
  brackets: [
    ["{", "}"],
    ["[", "]"],
    ["(", ")"],
    ["<", ">"],
  ],
  autoClosingPairs: [
    { open: "{", close: "}" },
    { open: "[", close: "]" },
    { open: "(", close: ")" },
    { open: "<", close: ">" },
    { open: "'", close: "'", notIn: ["string", "comment"] },
    { open: '"', close: '"', notIn: ["string", "comment"] },
  ],
  surroundingPairs: [
    { open: "{", close: "}" },
    { open: "[", close: "]" },
    { open: "(", close: ")" },
    { open: "<", close: ">" },
    { open: "'", close: "'" },
    { open: '"', close: '"' },
  ],
  folding: {
    markers: {
      start: new RegExp("^\\s*#region\\b"),
      end: new RegExp("^\\s*#endregion\\b"),
    },
  },
};

export const language = <languages.IMonarchLanguage>{
  defaultToken: "",
  tokenPostfix: ".al",
  ignoreCase: true,

  brackets: [
    { open: "{", close: "}", token: "delimiter.curly" },
    { open: "[", close: "]", token: "delimiter.square" },
    { open: "(", close: ")", token: "delimiter.parenthesis" },
    { open: "<", close: ">", token: "delimiter.angle" },
  ],

  keywords: [
    "begin",
    "else",
    "end",
    "if",
    "not",
    "then",
    "to",
    "downto",
    "var",
    "xor",
    "true",
    "false",
    "procedure",
    "trigger",
    "exit",
    "while",
    "do",
    "for",
    "repeat",
    "until",
  ],

  typeKeywords: [
    "boolean",
    "text",
    "code",
    "guid",
    "char",
    "integer",
    "decimal",
    "record",
  ],

  operators: [
    "=",
    ">",
    "<",
    "<=",
    ">=",
    "<>",
    ":",
    ":=",
    "+=",
    "-=",
    "*=",
    "/=",
    "and",
    "or",
    "+",
    "-",
    "*",
    "/",
    "mod",
    "div",
  ],

  // we include these common regular expressions
  // eslint-disable-next-line no-useless-escape
  symbols: /[=><:@\^&|+\-*\/\^%]+/,

  // The main tokenizer for our languages
  tokenizer: {
    root: [
      // identifiers and keywords
      [
        /[a-zA-Z_][\w]*|"[^"]*"/,
        {
          cases: {
            "@typeKeywords": "keyword.type",
            "@keywords": { token: "keyword.$0" },
            "@default": "identifier",
          },
        },
      ],

      // whitespace
      { include: "@whitespace" },

      // delimiters and operators
      // eslint-disable-next-line no-useless-escape
      [/[{}()\[\]]/, "@brackets"],
      [/[<>](?!@symbols)/, "@brackets"],
      [
        /@symbols/,
        {
          cases: {
            "@operators": "delimiter",
            "@default": "",
          },
        },
      ],

      // numbers
      // eslint-disable-next-line no-useless-escape
      [/\d*\.\d+([eE][\-+]?\d+)?/, "number.float"],
      [/\$[0-9a-fA-F]{1,16}/, "number.hex"],
      [/\d+/, "number"],

      // delimiter: after number because of .\d floats
      [/[;,.]/, "delimiter"],

      // strings
      [/'([^'\\]|\\.)*$/, "string.invalid"], // non-teminated string
      [/'/, "string", "@string"],

      // characters
      [/'[^\\']'/, "string"],
      [/'/, "string.invalid"],
      // eslint-disable-next-line no-useless-escape
      [/\#\d+/, "string"],
    ],

    comment: [
      // eslint-disable-next-line no-useless-escape
      [/[^\/*]+/, "comment"],
      ["\\*/", "comment", "@pop"],
      // eslint-disable-next-line no-useless-escape
      [/[\/*]/, "comment"],
    ],

    string: [
      [/[^\\']+/, "string"],
      [/\\./, "string.escape.invalid"],
      [/'/, { token: "string.quote", bracket: "@close", next: "@pop" }],
    ],

    whitespace: [
      [/[ \t\r\n]+/, "white"],
      [/\/\*/, "comment", "@comment"],
      [/\/\/.*$/, "comment"],
    ],
  },
};

const registerLanguage = (monaco: Monaco) => {
  const languageExtensionPoint: languages.ILanguageExtensionPoint = {
    id: "al",
    extensions: [".al"],
    aliases: ["AL"],
  };

  monaco.languages.register(languageExtensionPoint);

  monaco.languages.registerTokensProviderFactory(languageExtensionPoint.id, {
    create: async (): Promise<languages.IMonarchLanguage> => language,
  });
  monaco.languages.setLanguageConfiguration(languageExtensionPoint.id, conf);

  monaco.languages.registerCompletionItemProvider(languageExtensionPoint.id, {
    provideCompletionItems: async (model, position, context, token) => {
      // TODO
      // suggestions are:
      // - built-ins - static
      // - keywords - static
      // - snippets - procedure, trigger, loops, other?
      // - user functions - from parser
      // - local variables - from parser
      // - methods - static - but depend on current position
      // - records - "static" (send with ready event?) - but depend on current position
      // - record fields - "static" - but depend on current position

      // 1. parse code - all or only up to current position?
      // 2. return symbol table(s)?
      // this also might be the correct time to fix position handling in lexer?

      // TODO - skipIfBusy
      // Microsoft.Dynamics.NAV.InvokeExtensibilityMethod()
      // invoke with a key - use it to identify the response

      // TODO - check if completions box is shown?

      // Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(
      //   "whatever",
      //   ["some", "args"],
      //   true,
      //   () => {}
      // );

      await new Promise((r) => setTimeout(r, 300));

      const abortController = new AbortController();
      token.onCancellationRequested(() => abortController.abort());

      await LSPMessenger.instance.getSuggestions({
        input: "TODO", // TODO
        signal: abortController.signal,
      });

      const value = model.getValueInRange({
        startLineNumber: 0,
        startColumn: 0,
        endLineNumber: position.lineNumber,
        endColumn: position.column,
      });

      const word = model.getWordUntilPosition(position);
      const range = {
        startLineNumber: position.lineNumber,
        endLineNumber: position.lineNumber,
        startColumn: word.startColumn,
        endColumn: word.endColumn,
      };

      return {
        suggestions: [
          {
            label: "simpleText",
            kind: monaco.languages.CompletionItemKind.Text,
            insertText: "simpleText",
            range,
          },
          {
            label: "Abs",
            kind: monaco.languages.CompletionItemKind.Function,
            insertText: "Abs(${1:Number})",
            insertTextRules:
              monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            range,
          },
          {
            label: "Function snippet (tprocedure)",
            kind: monaco.languages.CompletionItemKind.Snippet,
            insertText: [
              "procedure $1()",
              "var",
              "\tmyInt: Integer;",
              "begin",
              "\t$0",
              "end;",
            ].join("\n"),
            insertTextRules:
              monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
            range,
          },
        ],
      };
    },
  });
};

export default registerLanguage;
