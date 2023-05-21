codeunit 69320 "Record SetView FS" implements "Method FS"
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
    begin
        RecordRef := Self.GetValue();

        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        Node := ValueLinkedList.First();

        TextValue.SetValue(RecordRef.GetView(Node.Value().GetValue()));
        exit(TextValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('SetView');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Void);
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
        ParameterSymbol.InsertText('View', 1);
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}