type EditorSubscriptionCallback = (value: string) => void;
type UnsubscribeFunction = () => void;

export default class EditorManager {
  subscriptions: EditorSubscriptionCallback[];

  constructor() {
    this.subscriptions = [];
  }

  static instance = new EditorManager();

  subscribe(callback: EditorSubscriptionCallback): UnsubscribeFunction {
    this.subscriptions.push(callback);

    return () => {
      this.subscriptions = this.subscriptions.filter((e) => e !== callback);
    };
  }

  setValue(value: string) {
    for (const subscription of this.subscriptions) {
      subscription(value);
    }
  }
}
