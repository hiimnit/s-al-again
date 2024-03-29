// monarch language definition for al language
// created by combining pascal and csharp definitions from monaco-editor basic languages
// https://github.com/microsoft/monaco-editor/blob/main/src/basic-languages/pascal/pascal.ts
// https://github.com/microsoft/monaco-editor/blob/main/src/basic-languages/csharp/csharp.ts

import { languages } from "monaco-editor";

import { Monaco } from "@monaco-editor/react";

import LSPMessenger from "../LSPMessenger";

import type { CancellationToken, IRange, Position } from "monaco-editor";

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
    "guid",
    "date",
    "time",
    "datetime",
    "dateformula",
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

  // TODO monaco.languages.registerSignatureHelpProvider for function parameters?

  monaco.languages.registerTokensProviderFactory(languageExtensionPoint.id, {
    create: async (): Promise<languages.IMonarchLanguage> => language,
  });
  monaco.languages.setLanguageConfiguration(languageExtensionPoint.id, conf);
  monaco.languages.registerCompletionItemProvider(languageExtensionPoint.id, {
    provideCompletionItems: async (model, position, _, token) => {
      // TODO record methods like setrange and validate need special treatment - suggest fields

      const staticSymbols = LSPMessenger.instance.staticSymbols;
      if (!staticSymbols) {
        // FIXME add a text suggestion with the error?
        console.error("Static symbols are not defined.");

        return {
          suggestions: [],
        };
      }

      const result = await tryGetSuggestions({
        input: model.getValue(),
        position,
        token,
      });

      if (!result) {
        console.error(`Unexpected parsing result: ${result}`);

        return {
          suggestions: [],
        };
      }

      const word = model.getWordUntilPosition(position);
      const range = {
        startLineNumber: position.lineNumber,
        endLineNumber: position.lineNumber,
        startColumn: word.startColumn,
        endColumn: word.endColumn,
      };

      const completionItems: languages.CompletionItem[] = [];

      if (result.suggestions.unfinished === true) {
        addUnfinishedParsingWarningToCompletionItems({
          completionItems,
          monaco,
          range,
        });
      }

      if (result.suggestions.variables === true) {
        addVariablesToCompletionItems({
          variables: result.localVariables,
          completionItems,
          monaco,
          range,
        });
      }

      if (result.suggestions.functions === true) {
        addFunctionsToCompletionItems({
          functions: result.functions,
          completionItems,
          monaco,
          range,
        });
        addFunctionsToCompletionItems({
          functions: staticSymbols.builtinFunctions,
          completionItems,
          monaco,
          range,
        });
      }

      if (result.suggestions.identifier === true) {
        // TODO add selection from records with name autocomplete?
      }

      if (result.suggestions.keywords) {
        addKeywordsToCompletionItems({
          keywords: result.suggestions.keywords,
          completionItems,
          monaco,
          range,
        });
      }

      if (result.suggestions.types === true) {
        addTypesToCompletionItems({
          types: staticSymbols.types,
          completionItems,
          monaco,
          range,
        });
      }

      if (result.suggestions.propsOf) {
        addMethodsToCompletionItems({
          typePropeties: staticSymbols.types[result.suggestions.propsOf.type],
          completionItems,
          monaco,
          range,
        });

        if (result.suggestions.propsOf.type === "Record") {
          addFieldsToCompletionItems({
            fields:
              staticSymbols.tables[result.suggestions.propsOf.subtype]?.fields,
            completionItems,
            monaco,
            range,
          });
        }
      }

      if (result.suggestions.subtypesOf) {
        if (result.suggestions.subtypesOf === "Record") {
          addTablesToCompletionItems({
            tables: staticSymbols.tables,
            completionItems,
            monaco,
            range,
          });
        }
      }

      // TODO add snippets - at least for new function?

      return {
        suggestions: completionItems,
      };
    },
  });
};

const tryGetSuggestions = async ({
  input,
  position,
  token,
}: {
  input: string;
  position: Position;
  token: CancellationToken;
}): Promise<AlParsingResult | undefined> => {
  const abortController = new AbortController();
  token.onCancellationRequested(() =>
    abortController.abort(new Error("AbortError"))
  );

  try {
    return await LSPMessenger.instance.getSuggestions({
      input,
      position,
      signal: abortController.signal,
    });
  } catch (error: unknown) {
    if (error instanceof Error && error.message === "AbortError") {
      return undefined;
    }
  }
};

type CompletionItemAdderCommonProps = {
  completionItems: languages.CompletionItem[];
  range: IRange;
  monaco: Monaco;
};

const addUnfinishedParsingWarningToCompletionItems = ({
  completionItems,
  range,
  monaco,
}: CompletionItemAdderCommonProps) => {
  completionItems.push({
    label: "Could not parse the input :(",
    kind: monaco.languages.CompletionItemKind.Issue,
    insertText: "",
    sortText: `00-unfinished`,
    range,
  });
};

const addVariablesToCompletionItems = ({
  completionItems,
  variables,
  range,
  monaco,
}: CompletionItemAdderCommonProps & {
  variables: AlVariable[];
}): void => {
  for (const variable of variables) {
    completionItems.push({
      label: `${variable.name}: ${variable.type}`, // TODO also include subtype and length?
      kind: monaco.languages.CompletionItemKind.Variable,
      insertText: variable.name,
      sortText: `01-${variable.name}`,
      range,
    });
  }
};

const addFunctionsToCompletionItems = ({
  completionItems,
  functions,
  range,
  monaco,
}: CompletionItemAdderCommonProps & {
  functions: AlFunction[];
}): void => {
  for (const { name, detail, insertText, documentation } of functions) {
    completionItems.push({
      label: name,
      kind: monaco.languages.CompletionItemKind.Function,
      insertText,
      insertTextRules:
        monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      detail,
      documentation,
      sortText: `03-${name}`,
      range,
    });
  }
};

const addKeywordsToCompletionItems = ({
  completionItems,
  keywords,
  range,
  monaco,
}: CompletionItemAdderCommonProps & {
  keywords: AlType[];
}): void => {
  for (const keyword of keywords) {
    completionItems.push({
      label: keyword,
      kind: monaco.languages.CompletionItemKind.Keyword,
      insertText: keyword,
      sortText: `05-${keyword}`,
      range,
    });
  }
};

const addTypesToCompletionItems = ({
  completionItems,
  types,
  range,
  monaco,
}: CompletionItemAdderCommonProps & {
  types: AlTypes;
}): void => {
  for (const type of Object.keys(types)) {
    completionItems.push({
      label: type,
      kind: monaco.languages.CompletionItemKind.Class,
      insertText: type,
      range,
    });
  }
};

const addTablesToCompletionItems = ({
  completionItems,
  tables,
  range,
  monaco,
}: CompletionItemAdderCommonProps & {
  tables: AlTables;
}): void => {
  for (const [number, { name, caption, type, obsolete }] of Object.entries(
    tables
  )) {
    const quotedName = name.includes(" ") ? `"${name}"` : name;
    // FIXME correctly replace current text - partial field name/orphaned quote
    completionItems.push({
      label: quotedName,
      kind: monaco.languages.CompletionItemKind.Class,
      insertText: quotedName,
      detail: type,
      documentation: `${caption} (${number})`,
      tags: obsolete // TODO add reason?
        ? [monaco.languages.CompletionItemTag.Deprecated]
        : undefined,
      range,
    });
  }
};

const addMethodsToCompletionItems = ({
  completionItems,
  typePropeties,
  range,
  monaco,
}: CompletionItemAdderCommonProps & {
  typePropeties: AlTypeProperties | undefined;
}): void => {
  if (!typePropeties) {
    return;
  }

  for (const {
    name,
    insertText,
    detail,
    documentation,
  } of typePropeties.methods) {
    completionItems.push({
      label: name,
      kind: monaco.languages.CompletionItemKind.Method,
      insertText,
      insertTextRules:
        monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
      detail,
      documentation,
      sortText: `01-${name}`,
      range,
    });
  }
};

const addFieldsToCompletionItems = ({
  completionItems,
  fields,
  range,
  monaco,
}: CompletionItemAdderCommonProps & {
  fields: AlFields | undefined;
}): void => {
  if (!fields) {
    return;
  }

  for (const [
    number,
    { name, caption, type, length, obsolete, class: fieldClass },
  ] of Object.entries(fields)) {
    const quotedName = name.includes(" ") ? `"${name}"` : name;
    const label = length
      ? `${quotedName}: ${type}[${length}]`
      : `${quotedName}: ${type}`;

    // FIXME correctly replace current text - partial field name/orphaned quote
    completionItems.push({
      label: label,
      kind: monaco.languages.CompletionItemKind.Property,
      insertText: quotedName,
      detail: fieldClass,
      documentation: `${caption} (${number})`,
      sortText: `00-${name}`,
      tags: obsolete // TODO add reason?
        ? [monaco.languages.CompletionItemTag.Deprecated]
        : undefined,
      range,
    });
  }
};

export type StaticSymbols = {
  tables: AlTables;
  types: AlTypes;
  builtinFunctions: AlFunction[];
};

type AlTables = {
  [k in number]: AlTable;
};

type AlTable = {
  name: string;
  caption: string;
  type: string;
  fields: AlFields;
  obsolete?: string; // TODO option!
};

type AlFields = {
  [k in number]: AlField;
};

type AlField = {
  name: string;
  caption: string;
  type: string;
  length?: number;
  obsolete?: string; // TODO option!
  class: string;
};

type AlKeyword = string;

type AlType = string;

type AlTypes = {
  [k in string]: AlTypeProperties;
};

type AlTypeProperties = {
  methods: AlFunction[];
};

// TODO implement parameter hints
type AlFunction = {
  name: string;
  insertText: string;
  detail: string;
  documentation?: string;
};

export type AlParsingResult = {
  suggestions: AlSuggestions;
  localVariables: AlVariable[];
  functions: AlFunction[];
};

type AlSuggestions = {
  keywords?: AlKeyword[];
  identifier?: boolean;
  unfinished?: boolean;
  variables?: boolean;
  functions?: boolean;
  types?: boolean;
  propsOf?: AlPropsOf;
  subtypesOf?: AlType;
};

type AlPropsOf = {
  type: AlType;
  subtype: number; // XXX
};

type AlVariable = {
  name: string;
  type: string;
  sybtype?: string;
  length?: number;
  scope: string;
  pointer: boolean;
};

export default registerLanguage;
