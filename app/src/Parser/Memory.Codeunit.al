codeunit 69009 "Memory FS" // TODO or Stack/Runtime?
{
    var
        LocalVariables: array[50] of Interface "Value FS";
        LocalVariableCount: Integer;
        LocalVariableMap: Dictionary of [Text, Integer];

    procedure Init(SymbolTable: Codeunit "Symbol Table FS")
    var
        Symbol: Record "Symbol FS";
    begin
        if not SymbolTable.FindSet(Symbol) then
            exit;

        repeat
            DefineLocalVariable(Symbol);
        until not SymbolTable.Next(Symbol);
    end;

    local procedure DefineLocalVariable
    (
        Symbol: Record "Symbol FS"
    )
    var
        NumericValue: Codeunit "Numeric Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        TextValue: Codeunit "Text Value FS";
    begin
        if LocalVariableCount = ArrayLen(LocalVariables) then
            Error('Reached maximum allowed number of local variables %1.', ArrayLen(LocalVariables));

        LocalVariableCount += 1;
        LocalVariableMap.Add(Symbol.Name.ToLower(), LocalVariableCount);

        case Symbol.Type of
            Symbol.Type::Number:
                LocalVariables[LocalVariableCount] := NumericValue;
            Symbol.Type::Boolean:
                LocalVariables[LocalVariableCount] := BooleanValue;
            Symbol.Type::Text:
                LocalVariables[LocalVariableCount] := TextValue;
            else
                Error('Initilization of type %1 is not supported.', Symbol.Type);
        end;
    end;

    procedure Get(Name: Text): Interface "Value FS"
    begin
        exit(LocalVariables[LocalVariableMap.Get(Name.ToLower())]);
    end;

    procedure Set(Name: Text; Value: Interface "Value FS")
    begin
        // TODO currently it is possible to change the variable data type in runtime
        // >>>> semantic analysis should not let this happen (if implemented properly)
        LocalVariables[LocalVariableMap.Get(Name.ToLower())] := Value;
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