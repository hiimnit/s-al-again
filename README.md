# SAL2

Scripting in AL - attempt #2.

## app

Business Central extension adding a code editor for running scripts.

!TODO add an image

### What does it do?

Currently? Not much. Code is parsed, semantically analyzed and executed. Message with the memory state is displayed at the end of each procedure execution.

### Sample code

The entry point is a parameterless `trigger` called `OnRun`. You can define additional procedures (for now without reference parameters).
Global variables are not supported (yet?).

```sal
procedure WriteLineMultiplied(text: text; count: number)
begin
    WriteLine(text * count);
end;

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

    WriteLineMultiplied(text + ' ', 3);
end;
```

### Supported features

#### Data types

Right now only a handful of basic types is supported:

- `number` (for both integers and decimals)
- `boolean`
- `text`
  - methods
    - `ToLower(): Text`
    - `ToUpper(): Text`
    - `Contains(Text: Text): Boolean`
- `record`
  - methods
    - `FindFirst()[: Boolean]`
    - `FindLast()[: Boolean]`
    - `FindSet()[: Boolean]`
    - `Next([Steps: Number]): Number`
    - `SetRange(Field: Identifier, [FromValue: FieldType, [ToValue: FieldType]])`

#### Statements

- assignment (`:=`, `+=`, `-=`, `*=`, `/=`)
- `while` loop
- `for` loop (both `to` and `downto`)
- `repeat-until` loop
- `if` and `if-else` statement
- `exit` statement - both variants, with and without an expression

#### Operators

- unary operators
  - numeric (`+`, `-`)
  - boolean (`not`)
- binary operators
  - comparison (`<`, `<=`, `<>`, `>=`, `>`, `=`)
  - numeric (`+`, `-`, `*`, `/`, `mod`, `div`)
  - boolean (`and`, `or`, `xor`)
  - text (`+`, `*`)
    - !TODO explain `*` operator

#### Built-in functions

- `Message(Text: Text)`
- `Error(Text: Text)`
- `WriteLine(Text: Text)`
- `Abs(Number: Number): Number`
- `Power(Number: Number, Power: Number): Number`
- `Format(Input: Any): Text`

### Planned

1. n-arity functions
1. more built-in functions and methods
1. correct value vs. reference handling
1. `date`/`time`/`datetime`/`guid`

## editor

React app addin using the [Monaco Editor](https://github.com/microsoft/monaco-editor) for script input.
