codeunit 69221 "IsNullGuid Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('IsNullGuid');
    end;

    procedure GetReturnType(): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.BooleanSymbol());
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol: Record "Symbol FS";
    begin
        ParameterSymbol.InsertGuid('Guid', 1);
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"; ValueLinkedList: Codeunit "Value Linked List FS"): Interface "Value FS"
    var
        BooleanValue: Codeunit "Boolean Value FS";
        Value: Interface "Value FS";
    begin
        Value := ValueLinkedList.First().Value();

        BooleanValue.SetValue(IsNullGuid(Value.GetValue()));

        exit(BooleanValue);
    end;
}