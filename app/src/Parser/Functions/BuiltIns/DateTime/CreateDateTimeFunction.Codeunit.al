codeunit 69212 "CreateDateTime Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('CreateDateTime');
    end;

    procedure GetReturnType(): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.DateTimeSymbol());
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
        ParameterSymbol.InsertDate('Date', 1);
        ParameterSymbol.InsertTime('Time', 2);

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
        DateTimeValue: Codeunit "DateTime Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        Date, Time : Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        Date := ValueNode.Value();
        ValueNode := ValueNode.Next();
        Time := ValueNode.Value();

        DateTimeValue.SetValue(CreateDateTime(
            Date.GetValue(),
            Time.GetValue()
        ));

        exit(DateTimeValue);
    end;
}