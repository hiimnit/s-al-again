codeunit 69319 "Record GetView FS" implements "Method FS"
{
    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS";
    var
        ValueLinkedList: Codeunit "Value Linked List FS";
        Node: Codeunit "Value Linked List Node FS";
        TextValue: Codeunit "Text Value FS";
        RecordRef: RecordRef;
        UseNames: Boolean;
    begin
        RecordRef := Self.GetValue();

        UseNames := true;
        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        if ValueLinkedList.First(Node) then
            UseNames := Node.Value().GetValue();

        TextValue.SetValue(RecordRef.GetView(UseNames));
        exit(TextValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('GetView');
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
        if Arguments.GetCount() = 0 then
            exit;

        ParameterSymbol.InsertBoolean('UseNames', 1);
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}