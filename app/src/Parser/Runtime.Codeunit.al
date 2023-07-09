codeunit 69011 "Runtime FS"
{
    var
        MonacoEditor: ControlAddIn "Monaco Editor FS"; // TODO move behind an interface

    procedure Init
    (
        NewMonacoEditor: ControlAddIn "Monaco Editor FS"
    )
    begin
        MonacoEditor := NewMonacoEditor;
    end;

    procedure WriteLine(Text: Text)
    begin
        MonacoEditor.WriteLine(Text);
    end;

    var
        Functions: array[50] of Codeunit "User Function FS";
        FunctionMap: Dictionary of [Text[120], Integer];
        FunctionCount: Integer;

    procedure DefineFunction
    (
        UserFunction: Codeunit "User Function FS"
    )
    begin
        if FunctionCount = ArrayLen(Functions) then
            Error('Reached maximum allowed number of local functions %1.', ArrayLen(Functions));

        FunctionCount += 1;
        FunctionMap.Add(UserFunction.GetName().ToLower(), FunctionCount);
        Functions[FunctionCount] := UserFunction;
    end;

    procedure LookupFunction(Name: Text[120]): Interface "Function FS"
    var
        i: Integer;
    begin
        if FunctionMap.ContainsKey(Name.ToLower()) then begin
            i := FunctionMap.Get(Name.ToLower());
            exit(Functions[i]);
        end;

        exit(LookupBuiltInFunction(Name));
    end;

    procedure GetLastDefinedFunction(): Codeunit "User Function FS"
    begin
        exit(Functions[FunctionCount]);
    end;

    procedure GetLastDefinedFunction(var UserFunction: Codeunit "User Function FS"): Boolean
    begin
        if FunctionCount = 0 then
            exit(false);

        UserFunction := GetLastDefinedFunction();
        exit(true);
    end;

    procedure GetFunctionCount(): Integer
    begin
        exit(FunctionCount);
    end;

    procedure GetFunction(i: Integer): Codeunit "User Function FS"
    begin
        exit(Functions[i]);
    end;

    local procedure LookupBuiltInFunction(Name: Text[120]): Interface "Function FS"
    var
        AbsFunction: Codeunit "Abs Function FS";
        PowerFunction: Codeunit "Power Function FS";
        MessageFunction: Codeunit "Message Function FS";
        ErrorFunction: Codeunit "Error Function FS";
        WriteLineFunction: Codeunit "Write Line Function FS";
        FormatFunction: Codeunit "Format Function FS";
        CalcDateFunction: Codeunit "CalcDate Function FS";
        ClosingDateFunction: Codeunit "ClosingDate Function FS";
        CreateDateTimeFunction: Codeunit "CreateDateTime Function FS";
        CurrentDateTimeFunction: Codeunit "CurrentDateTime Function FS";
        NormalDateFunction: Codeunit "NormalDate Function FS";
        TimeFunction: Codeunit "Time Function FS";
        TodayFunction: Codeunit "Today Function FS";
        WorkDateFunction: Codeunit "WorkDate Function FS";
        Date2DMYFunction: Codeunit "Date2DMY Function FS";
        Date2DWYFunction: Codeunit "Date2DWY Function FS";
        DMY2DateFunction: Codeunit "DMY2Date Function FS";
        DWY2DateFunction: Codeunit "DWY2Date Function FS";
        DT2DateFunction: Codeunit "DT2Date Function FS";
        DT2TimeFunction: Codeunit "DT2Time Function FS";
        CreateGuidFunction: Codeunit "CreateGuid Function FS";
        IsNullGuidFunction: Codeunit "IsNullGuid Function FS";
        EvaluateFunction: Codeunit "Evaluate Function FS";
        MaxStrLenFunction: Codeunit "MaxStrLen Function FS";
        ConvertStrFunction: Codeunit "ConvertStr Function FS";
        CopyStrFunction: Codeunit "CopyStr Function FS";
        DelChrFunction: Codeunit "DelChr Function FS";
        DelStrFunction: Codeunit "DelStr Function FS";
        IncStrFunction: Codeunit "IncStr Function FS";
        InsStrFunction: Codeunit "InsStr Function FS";
        LowerCaseFunction: Codeunit "LowerCase Function FS";
        PadStrFunction: Codeunit "PadStr Function FS";
        SelectStrFunction: Codeunit "SelectStr Function FS";
        StrCheckSumFunction: Codeunit "StrCheckSum Function FS";
        StrLenFunction: Codeunit "StrLen Function FS";
        StrPosFunction: Codeunit "StrPos Function FS";
        StrSubstNoFunction: Codeunit "StrSubstNo Function FS";
        UpperCaseFunction: Codeunit "UpperCase Function FS";
    begin
        case Name.ToLower() of
            AbsFunction.GetName().ToLower():
                exit(AbsFunction);
            PowerFunction.GetName().ToLower():
                exit(PowerFunction);
            MessageFunction.GetName().ToLower():
                exit(MessageFunction);
            ErrorFunction.GetName().ToLower():
                exit(ErrorFunction);
            WriteLineFunction.GetName().ToLower():
                exit(WriteLineFunction);
            FormatFunction.GetName().ToLower():
                exit(FormatFunction);
            CalcDateFunction.GetName().ToLower():
                exit(CalcDateFunction);
            ClosingDateFunction.GetName().ToLower():
                exit(ClosingDateFunction);
            CreateDateTimeFunction.GetName().ToLower():
                exit(CreateDateTimeFunction);
            CurrentDateTimeFunction.GetName().ToLower():
                exit(CurrentDateTimeFunction);
            NormalDateFunction.GetName().ToLower():
                exit(NormalDateFunction);
            TimeFunction.GetName().ToLower():
                exit(TimeFunction);
            TodayFunction.GetName().ToLower():
                exit(TodayFunction);
            WorkDateFunction.GetName().ToLower():
                exit(WorkDateFunction);
            Date2DMYFunction.GetName().ToLower():
                exit(Date2DMYFunction);
            Date2DWYFunction.GetName().ToLower():
                exit(Date2DWYFunction);
            DMY2DateFunction.GetName().ToLower():
                exit(DMY2DateFunction);
            DWY2DateFunction.GetName().ToLower():
                exit(DWY2DateFunction);
            DT2DateFunction.GetName().ToLower():
                exit(DT2DateFunction);
            DT2TimeFunction.GetName().ToLower():
                exit(DT2TimeFunction);
            CreateGuidFunction.GetName().ToLower():
                exit(CreateGuidFunction);
            IsNullGuidFunction.GetName().ToLower():
                exit(IsNullGuidFunction);
            EvaluateFunction.GetName().ToLower():
                exit(EvaluateFunction);
            MaxStrLenFunction.GetName().ToLower():
                exit(MaxStrLenFunction);
            ConvertStrFunction.GetName().ToLower():
                exit(ConvertStrFunction);
            CopyStrFunction.GetName().ToLower():
                exit(CopyStrFunction);
            DelChrFunction.GetName().ToLower():
                exit(DelChrFunction);
            DelStrFunction.GetName().ToLower():
                exit(DelStrFunction);
            IncStrFunction.GetName().ToLower():
                exit(IncStrFunction);
            InsStrFunction.GetName().ToLower():
                exit(InsStrFunction);
            LowerCaseFunction.GetName().ToLower():
                exit(LowerCaseFunction);
            PadStrFunction.GetName().ToLower():
                exit(PadStrFunction);
            SelectStrFunction.GetName().ToLower():
                exit(SelectStrFunction);
            StrCheckSumFunction.GetName().ToLower():
                exit(StrCheckSumFunction);
            StrLenFunction.GetName().ToLower():
                exit(StrLenFunction);
            StrPosFunction.GetName().ToLower():
                exit(StrPosFunction);
            StrSubstNoFunction.GetName().ToLower():
                exit(StrSubstNoFunction);
            UpperCaseFunction.GetName().ToLower():
                exit(UpperCaseFunction);
            else
                Error('Function %1 does not exist.', Name);
        end;
    end;

    procedure LookupEntryPoint(): Interface "Function FS"
    begin
        exit(LookupFunction('OnRun'));
    end;

    procedure ValidateFunctionsSemantics(Self: Codeunit "Runtime FS")
    var
        FunctionIndex: Integer;
    begin
        foreach FunctionIndex in FunctionMap.Values() do
            Functions[FunctionIndex].ValidateSemantics(Self);
    end;

    var
        MemoryStack: array[50] of Codeunit "Memory FS";
        MemoryCounter: Integer;

    procedure PushMemory(Memory: Codeunit "Memory FS")
    begin
        if MemoryCounter = ArrayLen(MemoryStack) then
            Error('Reached maximum allowed number of stack frames %1.', ArrayLen(MemoryStack));

        MemoryCounter += 1;
        MemoryStack[MemoryCounter] := Memory;
    end;

    procedure PopMemory(): Codeunit "Memory FS"
    begin
        if MemoryCounter = 0 then
            Error('There is nothing to pop.');

        // TODO investigate - clear caused issues here, BC does not count references properly?
        // Clear(MemoryStack[MemoryCounter]);
        MemoryCounter -= 1;
    end;

    procedure GetMemory(): Codeunit "Memory FS"
    begin
        exit(MemoryStack[MemoryCounter]);
    end;

    var
        Exited: Boolean;

    procedure SetExited()
    begin
        Exited := true;
    end;

    procedure IsExited(): Boolean
    begin
        exit(Exited);
    end;

    procedure ResetExited()
    begin
        Exited := false;
    end;

    procedure LookupMethod
    (
        Type: Enum "Type FS";
        Name: Text[120]
    ): Interface "Method FS"
    begin
        case Type of
            Type::Text,
            Type::Code:
                exit(LookupTextMethod(Name));
            Type::Record:
                exit(LookupRecordMethod(Name));
            else
                Error('Unknown %1 method %2.', Type, Name);
        end;
    end;

    procedure LookupTextMethod
    (
        Name: Text[120]
    ): Interface "Method FS"
    var
        TextToUpper: Codeunit "Text ToUpper FS";
        TextToLower: Codeunit "Text ToLower FS";
        TextContains: Codeunit "Text Contains FS";
        TextEndsWith: Codeunit "Text EndsWith FS";
        TextIndexOf: Codeunit "Text IndexOf FS";
        TextIndexOfAny: Codeunit "Text IndexOfAny FS";
        TextLastIndexOf: Codeunit "Text LastIndexOf FS";
        TextPadLeft: Codeunit "Text PadLeft FS";
        TextPadRight: Codeunit "Text PadRight FS";
        TextRemove: Codeunit "Text Remove FS";
        TextReplace: Codeunit "Text Replace FS";
        TextStartsWith: Codeunit "Text StartsWith FS";
        TextSubstring: Codeunit "Text Substring FS";
        TextTrim: Codeunit "Text Trim FS";
        TextTrimEnd: Codeunit "Text TrimEnd FS";
        TextTrimStart: Codeunit "Text TrimStart FS";
    begin
        case Name.ToLower() of
            TextToUpper.GetName().ToLower():
                exit(TextToUpper);
            TextToLower.GetName().ToLower():
                exit(TextToLower);
            TextContains.GetName().ToLower():
                exit(TextContains);
            TextEndsWith.GetName().ToLower():
                exit(TextEndsWith);
            TextIndexOf.GetName().ToLower():
                exit(TextIndexOf);
            TextIndexOfAny.GetName().ToLower():
                exit(TextIndexOfAny);
            TextLastIndexOf.GetName().ToLower():
                exit(TextLastIndexOf);
            TextPadLeft.GetName().ToLower():
                exit(TextPadLeft);
            TextPadRight.GetName().ToLower():
                exit(TextPadRight);
            TextRemove.GetName().ToLower():
                exit(TextRemove);
            TextReplace.GetName().ToLower():
                exit(TextReplace);
            TextStartsWith.GetName().ToLower():
                exit(TextStartsWith);
            TextSubstring.GetName().ToLower():
                exit(TextSubstring);
            TextTrim.GetName().ToLower():
                exit(TextTrim);
            TextTrimEnd.GetName().ToLower():
                exit(TextTrimEnd);
            TextTrimStart.GetName().ToLower():
                exit(TextTrimStart);
            else
                Error('Unknown Text method %1.', Name);
        end;
    end;

    local procedure LookupRecordMethod
    (
        Name: Text[120]
    ): Interface "Method FS"
    var
        RecordFindFirst: Codeunit "Record FindFirst FS";
        RecordFindLast: Codeunit "Record FindLast FS";
        RecordFindSet: Codeunit "Record FindSet FS";
        RecordNext: Codeunit "Record Next FS";
        RecordSetRange: Codeunit "Record SetRange FS";
        RecordInsert: Codeunit "Record Insert FS";
        RecordModify: Codeunit "Record Modify FS";
        RecordDelete: Codeunit "Record Delete FS";
        RecordInit: Codeunit "Record Init FS";
        RecordReset: Codeunit "Record Reset FS";
        RecordIsEmpty: Codeunit "Record IsEmpty FS";
        RecordTableName: Codeunit "Record TableName FS";
        RecordTableCaption: Codeunit "Record TableCaption FS";
        RecordSetRecFilter: Codeunit "Record SetRecFilter FS";
        RecordGetFilters: Codeunit "Record GetFilters FS";
        RecordCount: Codeunit "Record Count FS";
        RecordGetView: Codeunit "Record GetView FS";
        RecordSetView: Codeunit "Record SetView FS";
        RecordFieldNo: Codeunit "Record FieldNo FS";
        RecordValidate: Codeunit "Record Validate FS";
        RecordSetFilter: Codeunit "Record SetFilter FS";
    begin
        case Name.ToLower() of
            RecordFindFirst.GetName().ToLower():
                exit(RecordFindFirst);
            RecordFindLast.GetName().ToLower():
                exit(RecordFindLast);
            RecordFindSet.GetName().ToLower():
                exit(RecordFindSet);
            RecordNext.GetName().ToLower():
                exit(RecordNext);
            RecordSetRange.GetName().ToLower():
                exit(RecordSetRange);
            RecordSetFilter.GetName().ToLower():
                exit(RecordSetFilter);
            RecordValidate.GetName().ToLower():
                exit(RecordValidate);
            RecordInsert.GetName().ToLower():
                exit(RecordInsert);
            RecordModify.GetName().ToLower():
                exit(RecordModify);
            RecordDelete.GetName().ToLower():
                exit(RecordDelete);
            RecordInit.GetName().ToLower():
                exit(RecordInit);
            RecordReset.GetName().ToLower():
                exit(RecordReset);
            RecordIsEmpty.GetName().ToLower():
                exit(RecordIsEmpty);
            RecordTableName.GetName().ToLower():
                exit(RecordTableName);
            RecordTableCaption.GetName().ToLower():
                exit(RecordTableCaption);
            RecordSetRecFilter.GetName().ToLower():
                exit(RecordSetRecFilter);
            RecordGetFilters.GetName().ToLower():
                exit(RecordGetFilters);
            RecordCount.GetName().ToLower():
                exit(RecordCount);
            RecordGetView.GetName().ToLower():
                exit(RecordGetView);
            RecordSetView.GetName().ToLower():
                exit(RecordSetView);
            RecordFieldNo.GetName().ToLower():
                exit(RecordFieldNo);
            else
                Error('Unknown Record method %1.', Name);
        end;
    end;

    procedure ValidateMethodCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Name: Text[120];
        Arguments: Codeunit "Node Linked List FS";
        var ParameterSymbol: Record "Symbol FS"
    )
    var
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if Arguments.GetCount() <> ParameterSymbol.Count() then
            Error('Parameter count missmatch when calling method %1.', Name);

        ParameterSymbol.SetCurrentKey(Order); // TODO this feels wrong
        if not ParameterSymbol.FindSet() then
            exit;

        ArgumentNode := Arguments.First();
        while true do begin
            TestParameterVsArgument(
                Runtime,
                SymbolTable,
                Name,
                ParameterSymbol,
                ArgumentNode
            );

            if ParameterSymbol.Next() = 0 then
                break;
            ArgumentNode := ArgumentNode.Next();
        end;
    end;

    procedure TestParameterVsArgument
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Name: Text[120];
        ExpectedSymbol: Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS"
    )
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);

        TestParameterVsArgument(
            Runtime,
            SymbolTable,
            Name,
            ExpectedSymbol,
            ArgumentNode,
            Symbol
        );
    end;

    procedure TestParameterVsArgument
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Name: Text[120];
        ExpectedSymbol: Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS";
        Symbol: Record "Symbol FS"
    )
    begin
        if ExpectedSymbol."Pointer Parameter" then begin
            if not ArgumentNode.Value().Assignable() then
                Error('Var parameter %1 must be an assignable variable.', ExpectedSymbol.Name);

            if MatchTypesAnyOrExact(ExpectedSymbol, Symbol) then
                exit;

            // TODO different error for var parameters?
        end else
            if MatchTypesAnyOrCoercible(ExpectedSymbol, Symbol) then
                exit;

        Error(
            'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
            Name,
            ExpectedSymbol.TypeToText(),
            Symbol.TypeToText()
        );
    end;

    procedure MatchTypesAnyOrCoercible
    (
        ExpectedSymbol: Record "Symbol FS";
        ActualSymbol: Record "Symbol FS"
    ): Boolean
    begin
        if ExpectedSymbol.Type = ExpectedSymbol.Type::Any then
            exit(ActualSymbol.Type <> ActualSymbol.Type::Void);
        exit(MatchTypesCoercible(ExpectedSymbol, ActualSymbol));
    end;

    procedure MatchTypesAnyOrExact
    (
        ExpectedSymbol: Record "Symbol FS";
        ActualSymbol: Record "Symbol FS"
    ): Boolean
    begin
        if ExpectedSymbol.Type = ExpectedSymbol.Type::Any then
            exit(ActualSymbol.Type <> ActualSymbol.Type::Void);
        exit(ExpectedSymbol.CompareExact(ActualSymbol));
    end;

    procedure MatchTypesCoercible
    (
        ExpectedSymbol: Record "Symbol FS";
        ActualSymbol: Record "Symbol FS"
    ): Boolean
    begin
        if ExpectedSymbol.CompareExact(ActualSymbol) then
            exit(true);

        if ActualSymbol.CorercibleTo(ExpectedSymbol) then
            exit(true);

        exit(false);
    end;

    procedure EvaluateArguments
    (
        Runtime: Codeunit "Runtime FS";
        Arguments: Codeunit "Node Linked List FS"
    ): Codeunit "Value Linked List FS"
    var
        ArgumentNode: Codeunit "Node Linked List Node FS";
        ArgumentValues: Codeunit "Value Linked List FS";
    begin
        if not Arguments.First(ArgumentNode) then
            exit(ArgumentValues);

        exit(EvaluateArguments(Runtime, ArgumentNode));
    end;

    procedure EvaluateArguments
    (
        Runtime: Codeunit "Runtime FS";
        ArgumentNode: Codeunit "Node Linked List Node FS"
    ): Codeunit "Value Linked List FS"
    var
        ArgumentValues: Codeunit "Value Linked List FS";
    begin
        repeat
            ArgumentValues.Insert(
                ArgumentNode.Value().Evaluate(Runtime)
            );
        until not ArgumentNode.Next(ArgumentNode);

        exit(ArgumentValues);
    end;

    // limited (but simple) solution, 10 substitutions should be more than enough in most situations
    // can be improved by parsing the template string and handling substitutions? // TODO
    procedure SubstituteText(Template: Text; Node: Codeunit "Value Linked List Node FS"; Length: Integer): Text
    begin
        if Length = 0 then
            exit(Template);

        case Length of
            1:
                exit(StrSubstNo(Template, NextNodeValue(Node)));
            2:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node)));
            3:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            4:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            5:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            6:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            7:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            8:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            9:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            10:
                exit(StrSubstNo(Template, NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node), NextNodeValue(Node)));
            else
                Error('Unimplemented: Too many arguments for text substitution.');
        end;
    end;

    procedure MaxAllowedSubstitutions(): Integer
    begin
        exit(10);
    end;

    local procedure NextNodeValue(var Node: Codeunit "Value Linked List Node FS"): Variant
    begin
        Node := Node.Next();
        exit(Node.Value().GetValue());
    end;

    // TODO new codeunit?
    procedure PrepareStaticSymbols(): JsonObject
    var
        Symbols: JsonObject;
    begin
        Symbols.Add(
            'tables',
            PrepareTablesSymbols()
        );
        Symbols.Add(
            'keywords',
            PrepareKeywordSymbols()
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

    local procedure PrepareKeywordSymbols(): JsonArray
    var
        Keywords: JsonArray;
    begin
        Keywords.Add('begin');
        Keywords.Add('end');
        Keywords.Add('procedure');
        Keywords.Add('var');
        Keywords.Add('if');
        Keywords.Add('then');
        Keywords.Add('else');
        Keywords.Add('repeat');
        Keywords.Add('until');
        Keywords.Add('for');
        Keywords.Add('foreach');
        Keywords.Add('in');
        Keywords.Add('to');
        Keywords.Add('downto');
        Keywords.Add('do');
        Keywords.Add('while');
        Keywords.Add('break');
        Keywords.Add('exit');
        Keywords.Add('trigger');

        exit(Keywords);
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
        TextMethods.Add(CreateFunctionSymbols('ToUpper', 'ToUpper(): Text'));
        TextMethods.Add(CreateFunctionSymbols('ToLower', 'ToLower(): Text'));
        TextMethods.Add(CreateFunctionSymbols('Contains', 'Contains(Value: Text): Boolean'));
        TextMethods.Add(CreateFunctionSymbols('EndsWith', 'EndsWith(Value: Text): Boolean'));
        TextMethods.Add(CreateFunctionSymbols('IndexOf', 'IndexOf(Value: Text, [StartIndex: Integer]): Integer'));
        TextMethods.Add(CreateFunctionSymbols('IndexOfAny', 'IndexOfAny(Values: Text, [StartIndex: Integer]): Integer'));
        TextMethods.Add(CreateFunctionSymbols('LastIndexOf', 'LastIndexOf(Value: Text, [StartIndex: Integer]): Integer'));
        TextMethods.Add(CreateFunctionSymbols('PadLeft', 'PadLeft(Count: Integer, [Char: Char]): Text'));
        TextMethods.Add(CreateFunctionSymbols('PadRight', 'PadRight(Count: Integer, [Char: Char]): Text'));
        TextMethods.Add(CreateFunctionSymbols('Remove', 'Remove(StartIndex: Integer, [Count: Integer]): Text'));
        TextMethods.Add(CreateFunctionSymbols('Replace', 'Replace(OldValue: Text, NewValue: Text): Text'));
        TextMethods.Add(CreateFunctionSymbols('StartsWith', 'StartsWith(Value: Text): Boolean'));
        TextMethods.Add(CreateFunctionSymbols('Substring', 'Substring(StartIndex: Integer, [Count: Integer]): Text'));
        TextMethods.Add(CreateFunctionSymbols('Trim', 'Trim(): Text'));
        TextMethods.Add(CreateFunctionSymbols('TrimEnd', 'TrimEnd([Chars: Text]): Text'));
        TextMethods.Add(CreateFunctionSymbols('TrimStart', 'TrimStart([Chars: Text]): Text'));

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
        RecordMethods.Add(CreateFunctionSymbols('FindFirst', 'FindFirst(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('FindLast', 'FindLast(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('FindSet', 'FindSet(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Next', 'Next([Steps: Integer]): Integer'));
        RecordMethods.Add(CreateFunctionSymbols('SetRange', 'SetRange(Field: Joker, [FromValue: Joker], [ToValue: Joker])'));
        RecordMethods.Add(CreateFunctionSymbols('Insert', 'Insert(RunTrigger: Boolean): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Modify', 'Modify(RunTrigger: Boolean): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Delete', 'Delete(RunTrigger: Boolean): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('Init', 'Init()'));
        RecordMethods.Add(CreateFunctionSymbols('Reset', 'Reset()'));
        RecordMethods.Add(CreateFunctionSymbols('IsEmpty', 'IsEmpty(): Boolean'));
        RecordMethods.Add(CreateFunctionSymbols('TableName', 'TableName(): Text'));
        RecordMethods.Add(CreateFunctionSymbols('TableCaption', 'TableCaption(): Text'));
        RecordMethods.Add(CreateFunctionSymbols('SetRecFilter', 'SetRecFilter()'));
        RecordMethods.Add(CreateFunctionSymbols('GetFilters', 'GetFilters(): Text'));
        RecordMethods.Add(CreateFunctionSymbols('Count', 'Count(): Integer'));
        RecordMethods.Add(CreateFunctionSymbols('GetView', 'GetView([UseNames: Boolean]): Text'));
        RecordMethods.Add(CreateFunctionSymbols('SetView', 'SetView(String: Text)'));
        RecordMethods.Add(CreateFunctionSymbols('FieldNo', 'FieldNo(Field: Joker): Integer'));
        RecordMethods.Add(CreateFunctionSymbols('Validate', 'Validate(Field: Joker, [NewValue: Joker])'));
        RecordMethods.Add(CreateFunctionSymbols('SetFilter', 'SetFilter(Field: Joker, String: Text, [Value: Joker, ...])', 'Up to 10 substitutions.'));

        exit(RecordMethods);
    end;

    local procedure PrepareBuiltInFunctionsSymbols(): JsonArray
    var
        BuiltInFunctions: JsonArray;
    begin
        BuiltInFunctions.Add(CreateFunctionSymbols('Abs', 'Abs(Number: Decimal): Decimal'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Power', 'Power(Number: Decimal, Power: Decimal): Decimal'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Message', 'Message(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Error', 'Error(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('WriteLine', 'WriteLine(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Format', 'Format(Input: Any, [Length: Integer, [FormatNumber: Integer/FormatString: Text]]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CalcDate', 'CalcDate(Formula: Text/DateFormula, [Date: Date]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('ClosingDate', 'ClosingDate(Date: Date): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CreateDateTime', 'CreateDateTime(Date: Date, Time: Time): DateTime'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CurrentDateTime', 'CurrentDateTime(): DateTime'));
        BuiltInFunctions.Add(CreateFunctionSymbols('NormalDate', 'NormalDate(Date: Date): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Time', 'Time(): Time'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Today', 'Today(): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('WorkDate', 'WorkDate([WorkDate: Date]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Date2DMY', 'Date2DMY(Date: Date, Part: Integer): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Date2DWY', 'Date2DWY(Date: Date, Part: Integer): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DMY2Date', 'DMY2Date(Day: Integer, [Month: Integer, [Year: Integer]]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DWY2Date', 'DWY2Date(WeekDay: Integer, [Week: Integer, [Year: Integer]]): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DT2Date', 'DT2Date(DateTime: DateTime): Date'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DT2Time', 'DT2Time(DateTime: DateTime): Time'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CreateGuid', 'CreateGuid(): Guid'));
        BuiltInFunctions.Add(CreateFunctionSymbols('IsNullGuid', 'IsNullGuid(Guid: Guid): Boolean'));
        BuiltInFunctions.Add(CreateFunctionSymbols('Evaluate', 'Evaluate(var Value: Any, Input: Text, [FormatNumber: Integer])[: Boolean]'));
        BuiltInFunctions.Add(CreateFunctionSymbols('MaxStrLen', 'MaxStrLen(Text: Text): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('ConvertStr', 'ConvertStr(String: Text, FromCharacters: Text, ToCharacters: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('CopyStr', 'CopyStr(String: Text, Position: Integer, [Length: Integer]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DelChr', 'DelChr(String: Text, [Where: Text], [Which: Text]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('DelStr', 'DelStr(String: Text, Position: Integer, [Length: Integer]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('IncStr', 'IncStr(String: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('InsStr', 'InsStr(String: Text, SubString: Text, Position: Integer): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('LowerCase', 'LowerCase(String: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('PadStr', 'PadStr(String: Text, Length: Integer, [FillCharacter: Text]): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('SelectStr', 'SelectStr(Number: Integer, CommaString: Text): Text'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrCheckSum', 'StrCheckSum(String: Text, [WeightString: Text], [Modulus: Integer]): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrLen', 'StrLen(String: Text): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrPos', 'StrPos(String: Text, SubString: Text): Integer'));
        BuiltInFunctions.Add(CreateFunctionSymbols('StrSubstNo', 'StrSubstNo(Text: Text, [Substitution: Any, ...])', 'Up to 10 substitutions.'));
        BuiltInFunctions.Add(CreateFunctionSymbols('UpperCase', 'UpperCase(String: Text): Text'));

        exit(BuiltInFunctions);
    end;

    procedure CreateFunctionSymbols
    (
        Name: Text;
        Detail: Text
    ): JsonObject
    begin
        exit(CreateFunctionSymbols(
            Name,
            Detail,
            ''
        ));
    end;

    procedure CreateFunctionSymbols
    (
        Name: Text;
        Detail: Text;
        Documentation: Text
    ): JsonObject
    var
        Function: JsonObject;
    begin
        Function.Add('name', Name);

        Function.Add('detail', Detail);

        if Documentation <> '' then
            Function.Add('documentation', Documentation);

        exit(Function);
    end;
}