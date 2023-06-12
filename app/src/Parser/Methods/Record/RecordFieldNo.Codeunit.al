codeunit 69321 "Record FieldNo FS" implements "Method FS"
{
    var
        FieldName: Text[120]; // TODO store field id instead?

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS";
    var
        IntegerValue: Codeunit "Integer Value FS";
        RecordRef: RecordRef;
    begin
        RecordRef := Self.GetValue();
        IntegerValue.SetValue(FindFieldId(RecordRef.Number(), FieldName));
        exit(IntegerValue);
    end;

    local procedure FindFieldId
    (
        TableId: Integer;
        Name: Text[120]
    ): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableId);
        Field.SetRange(FieldName, Name);
        Field.FindFirst();
        exit(Field."No.");
    end;

    procedure GetName(): Text[120];
    begin
        exit('FieldNo');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        exit(Enum::"Type FS"::Integer);
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
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if Arguments.GetCount() <> 1 then
            Error('Parameter count missmatch when calling method %1.', GetName());

        ArgumentNode := Arguments.First();
        ParameterSymbol := ArgumentNode.Value().ValidateSemanticsWithContext(Runtime, SymbolTable, Self);
        if not ParameterSymbol.Property then
            Error('Expected the first argument to be a property.');

        FieldName := ParameterSymbol.Name; // TODO bit of a hack
    end;
}