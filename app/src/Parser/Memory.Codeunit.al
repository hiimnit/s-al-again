codeunit 69009 "Memory FS" // TODO or Stack/Runtime?
{
    var
        LocalVariables: array[50] of Interface "Value FS";
        LocalVariableCount: Integer;
        LocalVariableMap: Dictionary of [Text, Integer];

    procedure DefineLocalVariable
    (
        Name: Text;
        Type: Enum "Built-in Type FS"
    )
    var
        NumericValue: Codeunit "Numeric Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        TextValue: Codeunit "Text Value FS";
    begin
        if LocalVariableCount = ArrayLen(LocalVariables) then
            Error('Reached maximum allowed number of local variables %1.', ArrayLen(LocalVariables));

        LocalVariableCount += 1;
        LocalVariableMap.Add(Name.ToLower(), LocalVariableCount); // TODO nice error if it already exists

        case Type of
            Type::Number:
                LocalVariables[LocalVariableCount] := NumericValue;
            Type::Boolean:
                LocalVariables[LocalVariableCount] := BooleanValue;
            Type::Text:
                LocalVariables[LocalVariableCount] := TextValue;
            else
                Error('Unimplemented built-in type initilization %1.', Type);
        end;
    end;

    procedure Get(Name: Text): Interface "Value FS"
    begin
        exit(LocalVariables[LocalVariableMap.Get(Name.ToLower())]);
    end;

    procedure Set(Name: Text; Value: Interface "Value FS")
    begin
        // TODO currently it is possible to change the variable data type in runtime
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