type SuggestionPromiseResolver = (result: string) => void;

type AlType =
  | "boolean"
  | "text"
  | "code"
  | "integer"
  | "decimal"
  | "char"
  | "guid"
  | "record"
  | "date"
  | "time"
  | "datetime"
  | "dateformula";

type TypeProps = {
  hasSubtypes?: boolean;
};

const alTypes: Record<string, TypeProps> = {
  boolean: {},
  text: {},
  code: {},
  integer: {},
  decimal: {},
  char: {},
  guid: {},
  record: {
    hasSubtypes: true,
    // TODO hasProperties
    // TODO methods
  },
  date: {},
  time: {},
  datetime: {},
  dateformula: {},
};

class SymbolCache {
  //
}

class LSPMessenger {
  counter = 0;
  map = new Map<number, SuggestionPromiseResolver>();

  static instance: LSPMessenger = new LSPMessenger();

  async getSuggestions({
    input,
    signal,
  }: {
    input: string;
    signal: AbortSignal;
  }): Promise<void> {
    new Promise<string>((resolve, reject) => {
      if (signal.aborted) {
        return reject(signal.reason);
      }

      const key = this.counter++;
      this.map.set(key, resolve);

      signal.addEventListener("abort", () => {
        this.removeKey(key);
        reject(signal.reason);
      });

      Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("GetSuggestions", [
        key,
        input,
        // TODO add position so that we can send the whole input? for parsing functions defined later (and globals in the future?)
      ]);
    });
  }

  receive(key: number, message: string) {
    const object = parseIncomingMessage(message);
    if (object === null) {
      return;
    }

    const resolver = this.map.get(key);
    if (!resolver) {
      return;
    }

    resolver.call(this, "TODO"); // TODO

    this.removeKey(key);
  }

  removeKey(key: number): boolean {
    return this.map.delete(key);
  }
}

const parseIncomingMessage = (message: string): object | null => {
  try {
    const parsed = JSON.parse(message);
    if (typeof parsed !== "object") {
      return null;
    }
    return parsed;
  } catch (error) {
    return null;
  }
};

export default LSPMessenger;
