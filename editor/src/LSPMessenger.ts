import type { Position } from "monaco-editor";
import { AlParsingResult, StaticSymbols } from "./al/al";

type SuggestionPromiseResolver = (result: AlParsingResult) => void;

class LSPMessenger {
  counter = 0;
  map = new Map<number, SuggestionPromiseResolver>();
  staticSymbols?: StaticSymbols;

  static instance: LSPMessenger = new LSPMessenger();

  async getSuggestions({
    input,
    position,
    signal,
  }: {
    input: string;
    position: Position;
    signal: AbortSignal;
  }): Promise<AlParsingResult | undefined> {
    if (window.Microsoft === undefined) {
      return undefined;
    }

    return new Promise<AlParsingResult>((resolve, reject) => {
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
        position.lineNumber,
        position.column,
      ]);
    });
  }

  receive(key: number, result: AlParsingResult) {
    const resolver = this.map.get(key);
    if (!resolver) {
      return;
    }

    resolver.call(this, result);

    this.removeKey(key);
  }

  removeKey(key: number): boolean {
    return this.map.delete(key);
  }
}

export default LSPMessenger;
