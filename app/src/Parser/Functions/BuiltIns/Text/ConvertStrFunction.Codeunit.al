codeunit 69225 "ConvertStr Function FS" implements "Function FS"
{
    SingleInstance = true;

    procedure GetName(): Text[120];
    begin
        exit('ConvertStr');
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
        ParameterSymbol.InsertText('FromCharacters', 2);
        ParameterSymbol.InsertText('ToCharacters', 3);

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
        Input, FromCharacters, ToCharacters : Interface "Value FS";
        Result: Text;
    begin
        Node := ValueLinkedList.First();
        Input := Node.Value();

        Node := Node.Next();
        FromCharacters := Node.Value();

        Node := Node.Next();
        ToCharacters := Node.Value();

        Result := ConvertStr(
            Input.GetValue(),
            FromCharacters.GetValue(),
            ToCharacters.GetValue()
        );
        TextValue.SetValue(Result);
        exit(TextValue);
    end;
}