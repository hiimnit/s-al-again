codeunit 69224 "CopyStr Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('CopyStr');
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
        ParameterSymbol.InsertInteger('Position', 2);
        if Arguments.GetCount() > 2 then
            ParameterSymbol.InsertInteger('Length', 3);

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
        Input, Position, Length : Interface "Value FS";
        Result: Text;
    begin
        Node := ValueLinkedList.First();
        Input := Node.Value();

        Node := Node.Next();
        Position := Node.Value();

        if not Node.HasNext() then begin
            Result := CopyStr(
                Input.GetValue(),
                Position.GetValue()
            );
            TextValue.SetValue(Result);
            exit(TextValue);
        end;

        Node := Node.Next();
        Length := Node.Value();

        Result := CopyStr(
            Input.GetValue(),
            Position.GetValue(),
            Length.GetValue()
        );
        TextValue.SetValue(Result);
        exit(TextValue);
    end;
}