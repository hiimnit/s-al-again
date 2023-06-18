// monarch language definition for al language
// created by combining pascal and csharp definitions from monaco-editor basic languages
// https://github.com/microsoft/monaco-editor/blob/main/src/basic-languages/pascal/pascal.ts
// https://github.com/microsoft/monaco-editor/blob/main/src/basic-languages/csharp/csharp.ts

import { languages } from "monaco-editor";

import { Monaco } from "@monaco-editor/react";

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
};

export default registerLanguage;
