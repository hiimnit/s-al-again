codeunit 69215 "Date2DWY Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Date2DWY');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.IntegerSymbol());
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
        ParameterSymbol.InsertInteger('Part', 2);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        IntegerValue: Codeunit "Integer Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        Date, Number : Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        Date := ValueNode.Value();
        ValueNode := ValueNode.Next();
        Number := ValueNode.Value();

        IntegerValue.SetValue(Date2DWY(
            Date.GetValue(),
            Number.GetValue()
        ));

        exit(IntegerValue);
    end;
}