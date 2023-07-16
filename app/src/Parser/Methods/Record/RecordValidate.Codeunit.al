codeunit 69322 "Record Validate FS" implements "Method FS"
{
    var
        FilterFieldName: Text[120]; // TODO store field id instead?

    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS";
    var
        ArgumentNode: Codeunit "Node Linked List Node FS";
        VoidValue: Codeunit "Void Value FS";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        Value: Interface "Value FS";
        FieldId: Integer;
    begin
        RecordRef := Self.GetValue();
        FieldId := FindFieldId(RecordRef.Number(), FilterFieldName);
        FieldRef := RecordRef.Field(FieldId);

        ArgumentNode := Arguments.First(); // skip first parameter

        if not ArgumentNode.HasNext() then begin
            FieldRef.Validate();
            exit(VoidValue);
        end;

        ArgumentNode := ArgumentNode.Next();
        Value := ArgumentNode.Value().Evaluate(Runtime);
        FieldRef.Validate(Value.GetValue());
        exit(VoidValue);
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
        exit('Validate');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
        // XXX return self? chaining setrange?
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
        Symbol, ParameterSymbol : Record "Symbol FS";
        ArgumentNode: Codeunit "Node Linked List Node FS";
    begin
        if not (Arguments.GetCount() in [1 .. 2]) then
            Error('Parameter count missmatch when calling method %1.', GetName());

        ArgumentNode := Arguments.First();
        ParameterSymbol := ArgumentNode.Value().ValidateSemanticsWithContext(Runtime, SymbolTable, Self);
        if not ParameterSymbol.Property then
            Error('Expected the first argument to be a property of %1.', Self.Name);

        FilterFieldName := ParameterSymbol.Name; // TODO bit of a hack

        if not ArgumentNode.HasNext() then
            exit;

        ArgumentNode := ArgumentNode.Next();
        Symbol := ArgumentNode.Value().ValidateSemantics(Runtime, SymbolTable);
        if not Runtime.MatchTypesAnyOrCoercible(ParameterSymbol, Symbol) then
            Error(
                'Parameter call missmatch when calling method %1.\\Expected %2, got %3.',
                GetName(),
                ParameterSymbol.TypeToText(),
                Symbol.TypeToText()
            );
    end;
}