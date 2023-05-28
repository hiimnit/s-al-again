codeunit 69214 "Date2DMY Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Date2DMY');
    end;

    procedure GetReturnType(): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.NumericSymbol());
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
        ParameterSymbol.InsertNumber('Part', 2);

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
        NumericValue: Codeunit "Numeric Value FS";
        ValueNode: Codeunit "Value Linked List Node FS";
        Date, Number : Interface "Value FS";
    begin
        ValueNode := ValueLinkedList.First();
        Date := ValueNode.Value();
        ValueNode := ValueNode.Next();
        Number := ValueNode.Value();

        NumericValue.SetValue(Date2DMY(
            Date.GetValue(),
            Number.GetValue()
        ));

        exit(NumericValue);
    end;
}