codeunit 69348 "Text TrimEnd FS" implements "Method FS"
{
    SingleInstance = true;

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS"
    var
        TextValue: Codeunit "Text Value FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        Node: Codeunit "Value Linked List Node FS";
        Text: Text;
    begin
        Text := Self.GetValue();

        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        if not ValueLinkedList.First(Node) then begin
            TextValue.SetValue(Text.TrimEnd());
            exit(TextValue);
        end;

        TextValue.SetValue(Text.TrimEnd(
            Node.Value().GetValue()
        ));
        exit(TextValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('TrimEnd');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Text);
    end;

    procedure ValidateCallArguments
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        Self: Record "Symbol FS";
        Arguments: Codeunit "Node Linked List FS"
    )
    var
        ParameterSymbol: Record "Symbol FS";
    begin
        if Arguments.GetCount() > 0 then
            ParameterSymbol.InsertText('Chars', 1);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}