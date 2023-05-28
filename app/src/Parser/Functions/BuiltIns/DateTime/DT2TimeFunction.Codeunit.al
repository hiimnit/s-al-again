codeunit 69219 "DT2Time Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('DT2Time');
    end;

    procedure GetReturnType(): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.TimeSymbol());
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
        TimeValue: Codeunit "Time Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        DateTime: Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        DateTime := ValueNode.Value();

        TimeValue.SetValue(DT2Time(
            DateTime.GetValue()
        ));

        exit(TimeValue);
    end;
}