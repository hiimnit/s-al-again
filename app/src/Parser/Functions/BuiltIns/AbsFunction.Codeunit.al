codeunit 69200 "Abs Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Abs');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
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
        ParameterSymbol.InsertNumber('Number', 1);

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
        NumericValue: Codeunit "Numeric Value FS";
        Node: Codeunit "Value Linked List Node FS";
        Value: Decimal;
    begin
        Node := ValueLinkedList.First();

        Value := Abs(Node.Value().GetValue());
        NumericValue.SetValue(Value);

        exit(NumericValue);
    end;
}