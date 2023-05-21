codeunit 69310 "Record Delete FS" implements "Method FS"
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
        VoidValue: Codeunit "Void Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        RecordRef: RecordRef;
        RunTrigger: Boolean;
    begin
        RecordRef := Self.GetValue();

        RunTrigger := false;
        ValueLinkedList := Runtime.EvaluateArguments(Runtime, Arguments);
        if ValueLinkedList.First(Node) then
            RunTrigger := Node.Value().GetValue();

        if TopLevel then begin
            RecordRef.Delete(RunTrigger);
            exit(VoidValue);
        end;

        BooleanValue.SetValue(RecordRef.Delete(RunTrigger));
        exit(BooleanValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('Delete');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        if TopLevel then
            exit(Enum::"Type FS"::Void);
        exit(Enum::"Type FS"::Boolean);
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

        ParameterSymbol.InsertBoolean('RunTrigger', 1);
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}