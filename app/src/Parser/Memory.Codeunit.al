codeunit 69009 "Memory FS"
{
    var
        LocalVariables: array[50] of Interface "Value FS"; // TODO wrap value?
        LocalVariableCount: Integer;
        LocalVariableMap: Dictionary of [Text, Integer];

    procedure Init(SymbolTable: Codeunit "Symbol Table FS"; ValueLinkedList: Codeunit "Value Linked List FS")
    var
        Symbol: Record "Symbol FS";
        Node: Codeunit "Value Linked List Node FS";
        Value: Interface "Value FS";
        FirstParameterGot: Boolean;
    begin
        if not SymbolTable.FindSet(Symbol) then
            exit;

        repeat
            case Symbol.Scope of
                Symbol.Scope::Local:
                    InitializeLocalVariable(Symbol);
                Symbol.Scope::Parameter:
                    begin
                        if not FirstParameterGot then begin
                            Node := ValueLinkedList.First();
                            FirstParameterGot := true;
                        end else
                            Node := Node.Next();

                        Value := Node.Value();
                        if not Symbol."Pointer Parameter" then
                            Value := Value.Copy();

                        InitializeSymbol(
                            Symbol,
                            Value
                        );
                    end;
                else
                    Error('Initialization is not implemented for scope %1.', Symbol.Scope);
            end;
        until not SymbolTable.Next(Symbol);
    end;

    local procedure InitializeLocalVariable
    (
        Symbol: Record "Symbol FS"
    )
    begin
        InitializeSymbol(
            Symbol,
            DefaultValueFromType(Symbol)
        );
    end;

    // TODO change to a "Validated Symbol"?
    procedure DefaultValueFromType(Symbol: Record "Symbol FS"): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        TextValue: Codeunit "Text Value FS";
        DateValue: Codeunit "Date Value FS";
        TimeValue: Codeunit "Time Value FS";
        DateTimeValue: Codeunit "DateTime Value FS";
        RecordValue: Codeunit "Record Value FS";
        Value: Interface "Value FS";
    begin
        case Symbol.Type of
            Symbol.Type::Number:
                Value := NumericValue;
            Symbol.Type::Boolean:
                Value := BooleanValue;
            Symbol.Type::Text:
                Value := TextValue;
            Symbol.Type::Date:
                Value := DateValue;
            Symbol.Type::Time:
                Value := TimeValue;
            Symbol.Type::DateTime:
                Value := DateTimeValue;
            Symbol.Type::Record:
                begin
                    RecordValue.Init(Symbol.Subtype);
                    Value := RecordValue;
                end;
            else
                Error('Initilization of type %1 is not supported.', Symbol.Type);
        end;

        exit(Value);
    end;

    local procedure InitializeSymbol
    (
        Symbol: Record "Symbol FS";
        Value: Interface "Value FS"
    )
    begin
        if LocalVariableCount = ArrayLen(LocalVariables) then
            Error('Reached maximum allowed number of local variables %1.', ArrayLen(LocalVariables));

        LocalVariableCount += 1;
        LocalVariableMap.Add(Symbol.Name.ToLower(), LocalVariableCount);
        LocalVariables[LocalVariableCount] := Value;
    end;

    procedure Get(Name: Text): Interface "Value FS"
    begin
        exit(LocalVariables[LocalVariableMap.Get(Name.ToLower())]);
    end;

    procedure Set(Name: Text; Value: Interface "Value FS")
    begin
        // TODO currently it is possible to change the variable data type in runtime
        // >>>> semantic analysis should not let this happen (if implemented properly)
        // TODO lets instead call setvalue to change the in-memory value instead of replacing it?
        // >>>> resolve as part of reference handling
        LocalVariables[LocalVariableMap.Get(Name.ToLower())].Mutate(Value);
    end;

    procedure DebugMessage()
    var
        TextBuilder: TextBuilder;
        k: Text;
    begin
        TextBuilder.Append('Memory:\\');
        foreach k in LocalVariableMap.Keys() do
            TextBuilder.Append(StrSubstNo('%1: %2\', k, LocalVariables[LocalVariableMap.Get(k)].GetValue()));
        Message(TextBuilder.ToText());
    end;
}