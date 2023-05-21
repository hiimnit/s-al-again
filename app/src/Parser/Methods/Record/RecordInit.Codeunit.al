codeunit 69311 "Record Init FS" implements "Method FS"
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
        RecordRef: RecordRef;
    begin
        RecordRef := Self.GetValue();
        RecordRef.Init();
        exit(VoidValue);
    end;

    procedure GetName(): Text[120];
    begin
        exit('Init');
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
        Runtime.ValidateMethodCallArguments(
            Runtime,
            SymbolTable,
            GetName(),
            Arguments,
            ParameterSymbol
        );
    end;
}