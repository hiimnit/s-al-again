type ReplaceEditorTextSubscriptionCallback = (value: string) => void;
type SymbolsReadyCallback = () => void;
type UnsubscribeFunction = () => void;

export default class EditorManager {
  replaceTextSubscriptions: ReplaceEditorTextSubscriptionCallback[];
  symbolsReadySubscriptions: SymbolsReadyCallback[];

  constructor() {
    this.replaceTextSubscriptions = [];
    this.symbolsReadySubscriptions = [];
  }

  static instance = new EditorManager();

  subscribe({
    replaceTextCallback,
    symbolsLoadedCallback: symbolsReadyCallback,
  }: {
    replaceTextCallback: ReplaceEditorTextSubscriptionCallback;
    symbolsLoadedCallback: SymbolsReadyCallback;
  }): UnsubscribeFunction {
    this.replaceTextSubscriptions.push(replaceTextCallback);
    this.symbolsReadySubscriptions.push(symbolsReadyCallback);

    return () => {
      this.replaceTextSubscriptions = this.replaceTextSubscriptions.filter(
        (e) => e !== replaceTextCallback
      );
      this.symbolsReadySubscriptions = this.symbolsReadySubscriptions.filter(
        (e) => e != symbolsReadyCallback
      );
    };
  }

  replaceEditorText(value: string) {
    for (const subscription of this.replaceTextSubscriptions) {
      subscription(value);
    }
  }

  notifySymbolsReady() {
    for (const subscription of this.symbolsReadySubscriptions) {
      subscription();
    }
  }
}
