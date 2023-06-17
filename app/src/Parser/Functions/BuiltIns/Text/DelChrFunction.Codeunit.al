codeunit 69226 "DelChr Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('DelChr');
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
        if Arguments.GetCount() > 1 then
            ParameterSymbol.InsertText('Where', 2);
        if Arguments.GetCount() > 2 then
            ParameterSymbol.InsertText('Which', 3);

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
        TextValue: Codeunit "Text Value FS";
        Input, Where, Which : Interface "Value FS";
        Result: Text;
    begin
        Node := ValueLinkedList.First();
        Input := Node.Value();

        if not Node.HasNext() then begin
            Result := DelChr(
                Input.GetValue()
            );
            TextValue.SetValue(Result);
            exit(TextValue);
        end;

        Node := Node.Next();
        Where := Node.Value();

        if not Node.HasNext() then begin
            Result := DelChr(
                Input.GetValue(),
                Where.GetValue()
            );
            TextValue.SetValue(Result);
            exit(TextValue);
        end;

        Node := Node.Next();
        Which := Node.Value();

        Result := DelChr(
            Input.GetValue(),
            Where.GetValue(),
            Which.GetValue()
        );
        TextValue.SetValue(Result);
        exit(TextValue);
    end;
}