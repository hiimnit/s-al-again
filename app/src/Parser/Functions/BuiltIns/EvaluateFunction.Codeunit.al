codeunit 69222 "Evaluate Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('Evaluate');
    end;

    procedure GetReturnType(TopLevel: Boolean): Record "Symbol FS"
    var
        SymbolTable: Codeunit "Symbol Table FS";
    begin
        if TopLevel then
            exit(SymbolTable.VoidSymbol());
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
        ParameterSymbol.InsertVarAny('Any', 1);
        ParameterSymbol.InsertText('Input', 2);
        if Arguments.GetCount() > 2 then
            ParameterSymbol.InsertNumber('FormatNumber', 3);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;

    // TODO evaluating numbers has issues - unexpected results when evaluating "integers"
    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        Node: Codeunit "Value Linked List Node FS";
        BooleanValue: Codeunit "Boolean Value FS";
        VoidValue: Codeunit "Void Value FS";
        Value, Input, Format : Interface "Value FS";
        Result: Boolean;
    begin
        Node := ValueLinkedList.First();
        Value := Node.Value();

        Node := Node.Next();
        Input := Node.Value();

        if not Node.HasNext() then begin
            Result := Value.Evaluate(Input.GetValue(), TopLevel);
            if TopLevel then
                exit(VoidValue);
            BooleanValue.SetValue(Result);
            exit(BooleanValue);
        end;

        Node := Node.Next();
        Format := Node.Value();

        Result := Value.Evaluate(Input.GetValue(), Format.GetValue(), TopLevel);
        if TopLevel then
            exit(VoidValue);
        BooleanValue.SetValue(Result);
        exit(BooleanValue);
    end;
}