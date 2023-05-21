codeunit 69313 "Record IsEmpty FS" implements "Method FS"
{
    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS";
    var
        BooleanValue: Codeunit "Boolean Value FS";
        RecordRef: RecordRef;
    begin
        RecordRef := Self.GetValue();
        BooleanValue.SetValue(RecordRef.IsEmpty());
        exit(BooleanValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('IsEmpty');
    end;

    procedure GetReturnType(TopLevel: Boolean): Enum "Type FS";
    begin
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
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}