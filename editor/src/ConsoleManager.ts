export type ConsoleSubscriptionCallback = (lines: ConsoleLine[]) => void;
export type UnsubscribeFunction = () => void;
export type ConsoleLine = {
  entryNo: number;
  content: string;
};

export default class ConsoleManager {
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
