# SAL2

Scripting in AL - attempt #2.

## app

Business Central extension adding a code editor for running scripts.

!TODO add an image

### What does it do?

Currently? Not much. Code is parsed, semantically analyzed and executed. Message with the memory state is displayed at the end of each procedure execution.

### Goals

1. Support copy-and-pasting existing AL code and running it without any changes
1. Add new features to make life easier

### Limitations

!TODO describe current implementation limitations

### Sample code

The entry point is a parameterless `trigger` called `OnRun`. You can define additional procedures with `var` parameters and (named) return values.
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

| type                                | status | remark                                                                                                                                                                                  |
|-------------------------------------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `boolean`                           | ✅      |                                                                                                                                                                                         |
| `text`                              | ✅ ⭕️   | Declaring maximum text length is not (yet) supported.                                                                                                                                   |
| `code`                              | ⭕️     | `code` varibles are not supported, but `code` fields can be used as if they were `text` fields.                                                                                         |
| `char`                              | ⭕️     | Planned.                                                                                                                                                                                |
| `byte`                              | ⭕️     | Planned.                                                                                                                                                                                |
| `guid`                              | ✅      |                                                                                                                                                                                         |
| `enum`                              | ⭕️     | Planned (but maybe not possible outside of record fields?).                                                                                                                             |
| `option`                            | ⭕️     | Planned.                                                                                                                                                                                |
| `number`                            | ✅      | Currently used for both `integer` and `decimal`.                                                                                                                                        |
| `integer`                           | ⭕️     | Planned, currently supported as `number`.                                                                                                                                               |
| `decimal`                           | ⭕️     | Planned, currently supported as `number`.                                                                                                                                               |
| `char`                              | ⭕️     |                                                                                                                                                                                         |
| `byte`                              | ⭕️     |                                                                                                                                                                                         |
| `date`                              | ✅      |                                                                                                                                                                                         |
| `time`                              | ✅      |                                                                                                                                                                                         |
| `datetime`                          | ✅      |                                                                                                                                                                                         |
| `dateformula`                       | ⭕️     |                                                                                                                                                                                         |
| `duration`                          | ⭕️     |                                                                                                                                                                                         |
| `record`                            | ✅ ⭕️   | Temporary records are not supported - yet.                                                                                                                                              |
| `recordid`                          | ⭕️     |                                                                                                                                                                                         |
| `recordref` & `fieldref` & `keyref` | ❓      | Should be possible to implement - at least partially.                                                                                                                                   |
| `blob` & `outstream` & `instream`   | ⭕️     |                                                                                                                                                                                         |
| `textbuilder`                       | ⭕️     |                                                                                                                                                                                         |
| `variant`                           | ❓      | Should be possible to implement - at least partially.                                                                                                                                   |
| `dialog`                            | ❓      | Low priority.                                                                                                                                                                           |
| `dictionary`                        | ❓      | Low priority.                                                                                                                                                                           |
| `list`                              | ❓      | Low priority.                                                                                                                                                                           |
| `codeunit`                          | ❌ ❓    | Runtime reflection for codeunits is not possible (at least as far as I know). `Codenit.Run(Integer)` is possible. It could be possible by generating another extension with "bindings"? |
| `page`                              | ❌ ❓    | Same as codeunits. `Page.Run(Integer)` is possible.                                                                                                                                     |
| `report`                            | ❌ ❓    | Same as codeunits. `Report.Run(Integer)` is possible.                                                                                                                                   |
| `json*`                             | ❓      | Low priority.                                                                                                                                                                           |
| `xml*`                              | ❓      | Low priority.                                                                                                                                                                           |
| `http*`                             | ❓      | Low priority.                                                                                                                                                                           |
| others                              | ❓      | No priority.                                                                                                                                                                            |

##### Key

- ✅ - supported
- ⭕️ - planned/partially supported
- ❓ - not supported/not planned
- ❌ - not possible

Right now only a handful of basic types is supported:

- `number` (for both integers and decimals - this may cause problems when formatting numbers)
- `boolean`
- `text`
  - methods
    - `ToLower(): Text`
    - `ToUpper(): Text`
    - `Contains(Text: Text): Boolean`
- `guid`
- `date`
- `time`
- `datetime`
- `record`
  - methods
    - `FindFirst()[: Boolean]`
    - `FindLast()[: Boolean]`
    - `FindSet()[: Boolean]`
    - `Next([Steps: Number]): Number`
    - `SetRange(Field: Identifier, [FromValue: FieldType, [ToValue: FieldType]])`
    - `SetFilter(Field: Identifier, Filter: Tex, [Substitution: Any, ...])` (up to 10 substitutions)
    - `Insert([RunTrigger: Boolean])[: Boolean]`
    - `Modify([RunTrigger: Boolean])[: Boolean]`
    - `Delete([RunTrigger: Boolean])[: Boolean]`
    - `Init()`
    - `Reset()`
    - `IsEmpty(): Boolean`
    - `TableName(): Text`
    - `TableCaption(): Text`
    - `SetRecFilter()`
    - `GetFilters(): Text`
    - `Count(): Number`
    - `GetView([UseNames: Boolean]): Text`
    - `SetView(View: Text)`
    - `FieldNo(Field: Identifier): Number`
    - `Validate(Field: Identifier, [FromValue: FieldType])`

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
  - date (`+`, `-`)
  - time (`+`, `-`)
  - datetime (`+`, `-`)

#### Built-in functions

- `Message(Text: Text, [Substitution: Any, ...])` (up to 10 substitutions)
- `Error(Text: Text, [Substitution: Any, ...])` (up to 10 substitutions)
- `WriteLine(Text: Text, [Substitution: Any, ...])` (up to 10 substitutions)
- `Abs(Number: Number): Number`
- `Power(Number: Number, Power: Number): Number`
- `Format(Input: Any, [Length: Number, [FormatNumber: Number]]): Text`
- `Format(Input: Any, [Length: Number, [FormatString: Text]]): Text`
- `CalcDate(Formula: Text, [Date: Date]): Date`
- `ClosingDate(Date: Date): Date`
- `CreateDateTime(Date: Date, Time: Time): DateTime`
- `CurrentDateTime(): DateTime`
- `NormalDate(Date: Date): Date`
- `Time(): Time`
- `Today(): Date`
- `WorkDate([WorkDate: Date]): Date`
- `Date2DMY(Date: Date, Part: Number): Number`
- `Date2DWY(Date: Date, Part: Number): Number`
- `DMY2Date(Day: Number, [Month: Number, [Year: Number]]): Date`
- `DWY2Date(WeekDay: Number, [Week: Number, [Year: Number]]): Date`
- `DT2Date(DateTime: DateTime): Date`
- `DT2Time(DateTime: DateTime): Time`
- `CreateGuid(): Guid`
- `IsNullGuid(Guid: Guid): Boolean`

### Planned

1. more built-in functions and methods
1. `guid`, `dateformula`, `option`, `enum`
1. replace `number` with `integer` and `decimal

## editor

React app addin using the [Monaco Editor](https://github.com/microsoft/monaco-editor) for script input.
