codeunit 69343 "Text Remove FS" implements "Method FS"
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
        StartIndex, Count : Interface "Value FS";
        Text: Text;
    begin
        Text := Self.GetValue();

        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        Node := ValueLinkedList.First();
        StartIndex := Node.Value();

        if not Node.HasNext() then begin
            TextValue.SetValue(Text.Remove(
                StartIndex.GetValue()
            ));
            exit(TextValue);
        end;

        Node := Node.Next();
        Count := Node.Value();

        TextValue.SetValue(Text.Remove(
            StartIndex.GetValue(),
            Count.GetValue()
        ));
        exit(TextValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('Remove');
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
        ParameterSymbol.InsertInteger('StartIndex', 1);
        if Arguments.GetCount() > 1 then
            ParameterSymbol.InsertInteger('Count', 2);

        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}