codeunit 69307 "Record Next FS" implements "Method FS"
{
    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        ValueLinkedList: Codeunit "Value Linked List FS";
        Node: Codeunit "Value Linked List Node FS";
        RecordRef: RecordRef;
        Steps: Integer;
    begin
        RecordRef := Self.GetValue();

        Steps := 1;
        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        if ValueLinkedList.First(Node) then
            Steps := Node.Value().GetValue();

        NumericValue.SetValue(RecordRef.Next(Steps));
        exit(NumericValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('Next');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Number);
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

        ParameterSymbol.InsertNumber('Steps', 1);
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}