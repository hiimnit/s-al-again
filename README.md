# SAL2

Scripting in AL - attempt #2.

## app

Business Central extension adding a code editor for running scripts.

!TODO add an image

### What does it do?

Currently? Not much. Code is parsed, semantically analyzed and executed. Message with the memory state is displayed at the end.

### Sample code

Procedures are not supported - yet.
Scripts start with a `var` keyword followed by variable declarations.

```sal
var
    hello: boolean;
    i: number;
begin
    hi := true;
    hey := false;
    hi := hey and true or hey;
    
    text := 'hello';
    text := text * 3;

    if hi then
        text := 'true';

    if not hi then
        text := 'true'
    else begin
        i := 1;
    end;

    text := '';
    for i := 10 downto 0 do begin
        text := text + '0 ';
    end;
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

## editor

React app addin for using the [Monaco Editor](https://github.com/microsoft/monaco-editor) for script input.
