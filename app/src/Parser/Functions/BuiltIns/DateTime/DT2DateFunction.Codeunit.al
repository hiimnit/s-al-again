codeunit 69218 "DT2Date Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('DT2Date');
    end;

    procedure GetReturnType(): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.DateSymbol());
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
        ParameterSymbol.InsertDateTime('DateTime', 1);

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
        DateValue: Codeunit "Date Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        DateTime: Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        DateTime := ValueNode.Value();

        DateValue.SetValue(DT2Date(
            DateTime.GetValue()
        ));

        exit(DateValue);
    end;
}