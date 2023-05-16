# SAL2

Scripting in AL - attempt #2.

## app

Business Central extension adding a code editor for running scripts.

!TODO add an image

### What does it do?

Currently? Not much. Code is parsed, semantically analyzed and executed. Message with the memory state is displayed at the end.

### Sample code

Procedures are not supported - yet.
Scripts start with a `var` keyword followed by variable declarations. **!TODO rewrite**

```sal
trigger OnRun()
var
    hello: boolean;
    text: text;
begin
    text := 'h' + 'e' + 'l' * 2 + 'o';
    hello := 'hello' = text;

    if hello then
        text += ' ' + 'world!';

    WriteLine(text);
end;
```

### Supported features

#### Data types

Right now only a handful of basic types is supported:

- `number` (for both integers and decimals)
- `boolean`
- `text`

#### Statements

- assignment (`:=`, `+=`, `-=`, `*=`, `/=`)
- `while` loop
- `for` loop (both `to` and `downto`)
- `repeat-until` loop
- `if` and `if-else` statement
- unary operators
  - numeric (`+`, `-`)
  - boolean (`not`)
- binary operators
  - comparison (`<`, `<=`, `<>`, `>=`, `>`, `=`)
  - numeric (`+`, `-`, `*`, `/`, `mod`, `div`)
  - boolean (`and`, `or`, `xor`)
  - text (`+`, `*`)

#### Built-in functions

- `Message(Text: Text)`
- `Error(Text: Text)`
- `WriteLine(Text: Text)`
- `Abs(Number: Number): Number`
- `Power(Number: Number, Power: Number): Number`

### Planned

1. function returns
1. records and methods
1. `date`/`time`/`datetime`

## editor

React app addin using the [Monaco Editor](https://github.com/microsoft/monaco-editor) for script input.
