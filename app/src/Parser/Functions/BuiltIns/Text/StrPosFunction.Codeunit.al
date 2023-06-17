codeunit 69235 "StrPos Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('StrPos');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        exit(SymbolTable.TextSymbol());
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
        ParameterSymbol.InsertText('String', 1);
        ParameterSymbol.InsertText('SubString', 2);

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
        Node: Codeunit "Value Linked List Node FS";
        IntegerValue: Codeunit "Integer Value FS";
        Input, SubString : Interface "Value FS";
        Result: Integer;
    begin
        Node := ValueLinkedList.First();
        Input := Node.Value();

        Node := Node.Next();
        SubString := Node.Value();

        Result := StrPos(
            Input.GetValue(),
            SubString.GetValue()
        );
        IntegerValue.SetValue(Result);
        exit(IntegerValue);
    end;
}