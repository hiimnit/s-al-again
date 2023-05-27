codeunit 69201 "Power Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Power');
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
        ParameterSymbol.InsertNumber('Number', 1);
        ParameterSymbol.InsertNumber('Power', 2);

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
        Node: Codeunit "Value Linked List Node FS";
        Number, Power, Result : Decimal;
    begin
        Node := ValueLinkedList.First();
        Number := Node.Value().GetValue();
        Node := Node.Next();
        Power := Node.Value().GetValue();

        Result := Power(Number, Power);
        NumericValue.SetValue(Result);

        exit(NumericValue);
    end;
}