codeunit 69005 "Static Symbols FS"
{
    procedure Prepare(): JsonObject
    var
        Symbols: JsonObject;
    begin
        Symbols.Add(
            'tables',
            PrepareTablesSymbols()
        );
        Symbols.Add(
            'types',
            PrepareTypesSymbols()
        );
        Symbols.Add(
            'builtinFunctions',
            PrepareBuiltInFunctionsSymbols()
        );
        // TODO snippets?
        exit(Symbols);
    end;

    local procedure PrepareTablesSymbols(): JsonObject
    var
        TableMetadata: Record "Table Metadata";
        Tables: JsonObject;
    begin
        if not TableMetadata.FindSet() then
            exit(Tables);

        repeat
            Tables.Add(Format(TableMetadata.ID), PrepareTableSymbols(TableMetadata));
        until TableMetadata.Next() = 0;

        exit(Tables);
    end;

    local procedure PrepareTableSymbols(TableMetadata: Record "Table Metadata"): JsonObject
    var
        Field: Record Field;
        Table, Property, Properties : JsonObject;
    begin
        Table.Add('name', TableMetadata.Name);
        Table.Add('caption', TableMetadata.Caption);
        Table.Add('type', Format(TableMetadata.TableType));
        if TableMetadata.ObsoleteState <> TableMetadata.ObsoleteState::No then
            Table.Add('obsolete', TableMetadata.ObsoleteState);
        Table.Add('fields', Properties);

        Field.SetRange(TableNo, TableMetadata.ID);
        Field.SetRange(Enabled, true);
        if Field.FindSet() then
            repeat
                Clear(Property);
                Property.Add('name', Field.FieldName);
                Property.Add('caption', Field."Field Caption");
                Property.Add('type', Format(Field.Type));
                if Field.Type in [Field.Type::Text, Field.Type::Code] then
                    Property.Add('length', Field.Len);
                if Field.ObsoleteState <> Field.ObsoleteState::No then
                    Property.Add('obsolete', Field.ObsoleteState);
                Property.Add('class', Format(Field.Class));

                Properties.Add(Format(Field."No."), Property);
            until Field.Next() = 0;

        exit(Table);
    end;

    local procedure PrepareTypesSymbols(): JsonObject
    var
        Types: JsonObject;
        EmptyObject: JsonObject;
    begin
        Types.Add('Boolean', EmptyObject);
        Types.Add('Text', PrepareTextProperties());
        Types.Add('Code', PrepareTextProperties());
        Types.Add('Integer', EmptyObject);
        Types.Add('Decimal', EmptyObject);
        Types.Add('Char', EmptyObject);
        Types.Add('Guid', EmptyObject);
        Types.Add('Record', PrepareRecordProperties());
        Types.Add('Date', EmptyObject);
        Types.Add('Time', EmptyObject);
        Types.Add('DateTime', EmptyObject);
        Types.Add('DateFormula', EmptyObject);

        exit(Types);
    end;

    local procedure PrepareTextProperties(): JsonObject
    var
        TextProperties: JsonObject;
    begin
        TextProperties.Add(
            'methods',
            PrepareTextMethods()
        );

        exit(TextProperties);
    end;

    local procedure PrepareTextMethods(): JsonArray
    var
        TextMethods: JsonArray;
    begin
        TextMethods.Add(CreateFunctionSymbols('ToUpper', 'ToUpper()', 'ToUpper(): Text'));
        TextMethods.Add(CreateFunctionSymbols('ToLower', 'ToLower()', 'ToLower(): Text'));
        TextMethods.Add(CreateFunctionSymbols('Contains', 'Contains($0)', 'Contains(Value: Text): Boolean'));
        TextMethods.Add(CreateFunctionSymbols('EndsWith', 'EndsWith($0)', 'EndsWith(Value: Text): Boolean'));
        TextMethods.Add(CreateFunctionSymbols('IndexOf', 'IndexOf($0)', 'IndexOf(Value: Text, [StartIndex: Integer]): Integer'));
        TextMethods.Add(CreateFunctionSymbols('IndexOfAny', 'IndexOfAny($0)', 'IndexOfAny(Values: Text, [StartIndex: Integer]): Integer'));
        TextMethods.Add(CreateFunctionSymbols('LastIndexOf', 'LastIndexOf($0)', 'LastIndexOf(Value: Text, [StartIndex: Integer]): Integer'));
        TextMethods.Add(CreateFunctionSymbols('PadLeft', 'PadLeft($0)', 'PadLeft(Count: Integer, [Char: Char]): Text'));
        TextMethods.Add(CreateFunctionSymbols('PadRight', 'PadRight($0)', 'PadRight(Count: Integer, [Char: Char]): Text'));
        TextMethods.Add(CreateFunctionSymbols('Remove', 'Remove($0)', 'Remove(StartIndex: Integer, [Count: Integer]): Text'));
        TextMethods.Add(CreateFunctionSymbols('Replace', 'Replace($0)', 'Replace(OldValue: Text, NewValue: Text): Text'));
        TextMethods.Add(CreateFunctionSymbols('StartsWith', 'StartsWith($0)', 'StartsWith(Value: Text): Boolean'));
        TextMethods.Add(CreateFunctionSymbols('Substring', 'Substring($0)', 'Substring(StartIndex: Integer, [Count: Integer]): Text'));
        TextMethods.Add(CreateFunctionSymbols('Trim', 'Trim()', 'Trim(): Text'));
        TextMethods.Add(CreateFunctionSymbols('TrimEnd', 'TrimEnd($0)', 'TrimEnd([Chars: Text]): Text'));
        TextMethods.Add(CreateFunctionSymbols('TrimStart', 'TrimStart($0)', 'TrimStart([Chars: Text]): Text'));

        exit(TextMethods);
    end;

    local procedure PrepareRecordProperties(): JsonObject
    var
        TextProperties: JsonObject;
    begin
        TextProperties.Add(
            'methods',
            PrepareRecordMethods()
        );

        exit(TextProperties);
    end;

    local procedure PrepareRecordMethods(): JsonArray
    var
        RecordMethods: JsonArray;
    begin
        RecordMethods.Add(CreateFunctionSymbols('FindFirst', 'FindFirst()', 'FindFirst(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('FindLast', 'FindLast()', 'FindLast(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('FindSet', 'FindSet()', 'FindSet(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Next', 'Next($0)', 'Next([Steps: Integer]): Integer'));
        RecordMethods.Add(CreateFunctionSymbols('SetRange', 'SetRange($0)', 'SetRange(Field: Joker, [FromValue: Joker], [ToValue: Joker])'));
        RecordMethods.Add(CreateFunctionSymbols('Insert', 'Insert($0)', 'Insert(RunTrigger: Boolean): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Modify', 'Modify($0)', 'Modify(RunTrigger: Boolean): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Delete', 'Delete($0)', 'Delete(RunTrigger: Boolean): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Init', 'Init()', 'Init()'));
        RecordMethods.Add(CreateFunctionSymbols('Reset', 'Reset()', 'Reset()'));
        RecordMethods.Add(CreateFunctionSymbols('IsEmpty', 'IsEmpty()', 'IsEmpty(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('TableName', 'TableName()', 'TableName(): Text'));
        RecordMethods.Add(CreateFunctionSymbols('TableCaption', 'TableCaption()', 'TableCaption(): Text'));
        RecordMethods.Add(CreateFunctionSymbols('SetRecFilter', 'SetRecFilter()', 'SetRecFilter()'));
        RecordMethods.Add(CreateFunctionSymbols('GetFilters', 'GetFilters()', 'GetFilters(): Text'));
        RecordMethods.Add(CreateFunctionSymbols('Count', 'Count()', 'Count(): Integer'));
        RecordMethods.Add(CreateFunctionSymbols('GetView', 'GetView($0)', 'GetView([UseNames: Boolean]): Text'));
        RecordMethods.Add(CreateFunctionSymbols('SetView', 'SetView($0)', 'SetView(String: Text)'));
        RecordMethods.Add(CreateFunctionSymbols('FieldNo', 'FieldNo($0)', 'FieldNo(Field: Joker): Integer'));
        RecordMethods.Add(CreateFunctionSymbols('Validate', 'Validate($0)', 'Validate(Field: Joker, [NewValue: Joker])'));
        RecordMethods.Add(CreateFunctionSymbols('SetFilter', 'SetFilter($0)', 'SetFilter(Field: Joker, String: Text, [Value: Joker, ...])', 'Up to 10 substitutions.'));

        exit(RecordMethods);
    end;

    local procedure PrepareBuiltInFunctionsSymbols(): JsonArray
    var
        BuiltInFunctions: JsonArray;
    begin
        BuiltInFunctions.Add(CreateFunctionSymbols('Abs', 'Abs($0)', 'Abs(Number: Decimal): Decimal'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Power', 'Power($0)', 'Power(Number: Decimal, Power: Decimal): Decimal'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Message', 'Message($0)', 'Message(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Error', 'Error($0)', 'Error(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('WriteLine', 'WriteLine($0)', 'WriteLine(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Format', 'Format($0)', 'Format(Input: Any, [Length: Integer, [FormatNumber: Integer/FormatString: Text]]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CalcDate', 'CalcDate($0)', 'CalcDate(Formula: Text/DateFormula, [Date: Date]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('ClosingDate', 'ClosingDate($0)', 'ClosingDate(Date: Date): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CreateDateTime', 'CreateDateTime($0)', 'CreateDateTime(Date: Date, Time: Time): DateTime'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CurrentDateTime', 'CurrentDateTime()', 'CurrentDateTime(): DateTime'));
        BuiltInFunctions.Add(CreateFunctionSymbols('NormalDate', 'NormalDate($0)', 'NormalDate(Date: Date): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Time', 'Time()', 'Time(): Time'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Today', 'Today()', 'Today(): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('WorkDate', 'WorkDate($0)', 'WorkDate([WorkDate: Date]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Date2DMY', 'Date2DMY($0)', 'Date2DMY(Date: Date, Part: Integer): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Date2DWY', 'Date2DWY($0)', 'Date2DWY(Date: Date, Part: Integer): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DMY2Date', 'DMY2Date($0)', 'DMY2Date(Day: Integer, [Month: Integer, [Year: Integer]]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DWY2Date', 'DWY2Date($0)', 'DWY2Date(WeekDay: Integer, [Week: Integer, [Year: Integer]]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DT2Date', 'DT2Date($0)', 'DT2Date(DateTime: DateTime): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DT2Time', 'DT2Time($0)', 'DT2Time(DateTime: DateTime): Time'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CreateGuid', 'CreateGuid()', 'CreateGuid(): Guid'));
        BuiltInFunctions.Add(CreateFunctionSymbols('IsNullGuid', 'IsNullGuid($0)', 'IsNullGuid(Guid: Guid): Boolean'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Evaluate', 'Evaluate($0)', 'Evaluate(var Value: Any, Input: Text, [FormatNumber: Integer])[: Boolean]'));
        BuiltInFunctions.Add(CreateFunctionSymbols('MaxStrLen', 'MaxStrLen($0)', 'MaxStrLen(Text: Text): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('ConvertStr', 'ConvertStr($0)', 'ConvertStr(String: Text, FromCharacters: Text, ToCharacters: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CopyStr', 'CopyStr($0)', 'CopyStr(String: Text, Position: Integer, [Length: Integer]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DelChr', 'DelChr($0)', 'DelChr(String: Text, [Where: Text], [Which: Text]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DelStr', 'DelStr($0)', 'DelStr(String: Text, Position: Integer, [Length: Integer]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('IncStr', 'IncStr($0)', 'IncStr(String: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('InsStr', 'InsStr($0)', 'InsStr(String: Text, SubString: Text, Position: Integer): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('LowerCase', 'LowerCase($0)', 'LowerCase(String: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('PadStr', 'PadStr($0)', 'PadStr(String: Text, Length: Integer, [FillCharacter: Text]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('SelectStr', 'SelectStr($0)', 'SelectStr(Number: Integer, CommaString: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrCheckSum', 'StrCheckSum($0)', 'StrCheckSum(String: Text, [WeightString: Text], [Modulus: Integer]): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrLen', 'StrLen($0)', 'StrLen(String: Text): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrPos', 'StrPos($0)', 'StrPos(String: Text, SubString: Text): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrSubstNo', 'StrSubstNo($0)', 'StrSubstNo(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('UpperCase', 'UpperCase($0)', 'UpperCase(String: Text): Text'));

        exit(BuiltInFunctions);
    end;

    procedure CreateFunctionSymbols
    (
        Name: Text;
        InsertText: Text;
        Detail: Text
    ): JsonObject
    begin
        exit(CreateFunctionSymbols(
            Name,
            InsertText,
            Detail,
            ''
        ));
    end;

    procedure CreateFunctionSymbols
    (
        Name: Text;
        InsertText: Text;
        Detail: Text;
        Documentation: Text
    ): JsonObject
    var
        Function: JsonObject;
    begin
        Function.Add('name', Name);
        Function.Add('insertText', InsertText);

        Function.Add('detail', Detail);
        if Documentation <> '' then
            Function.Add('documentation', Documentation);

        exit(Function);
    end;
}