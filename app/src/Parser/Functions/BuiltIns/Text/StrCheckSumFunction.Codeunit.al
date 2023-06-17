codeunit 69233 "StrCheckSum Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('StrCheckSum');
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
        ParameterSymbol.InsertText('String', 1);
        if Arguments.GetCount() > 1 then
            ParameterSymbol.InsertText('WeightString', 2);
        if Arguments.GetCount() > 2 then
            ParameterSymbol.InsertInteger('Modulus', 2);

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
        Input, WeightString, Modulus : Interface "Value FS";
        Result: Integer;
    begin
        Node := ValueLinkedList.First();
        Input := Node.Value();

        if not Node.HasNext() then begin
            Result := StrCheckSum(
                Input.GetValue()
            );
            IntegerValue.SetValue(Result);
            exit(IntegerValue);
        end;

        Node := Node.Next();
        WeightString := Node.Value();

        if not Node.HasNext() then begin
            Result := StrCheckSum(
                Input.GetValue(),
                WeightString.GetValue()
            );
            IntegerValue.SetValue(Result);
            exit(IntegerValue);
        end;

        Node := Node.Next();
        WeightString := Node.Value();

        Result := StrCheckSum(
            Input.GetValue(),
            WeightString.GetValue(),
            Modulus.GetValue()
        );
        IntegerValue.SetValue(Result);
        exit(IntegerValue);
    end;
}