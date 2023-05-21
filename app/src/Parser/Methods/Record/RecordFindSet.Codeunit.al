codeunit 69306 "Record FindSet FS" implements "Method FS"
{
    procedure Evaluate
    (
        Runtime: Codeunit "Runtime FS";
        Self: Interface "Value FS";
        Arguments: Codeunit "Node Linked List FS";
        TopLevel: Boolean
    ): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        RecordRef: RecordRef;
    begin
        RecordRef := Self.GetValue();

        if TopLevel then begin
            RecordRef.FindSet();
            exit(VoidValue);
        end;

        BooleanValue.SetValue(RecordRef.FindSet());
        exit(BooleanValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('FindSet');
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
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}