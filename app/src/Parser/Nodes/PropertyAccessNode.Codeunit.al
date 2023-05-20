codeunit 69028 "Property Access Node FS" implements "Node FS"
{
    var
        AccessorExpression: Interface "Node FS";
        Name: Text[120];

    procedure Init
    (
        NewAccessorExpression: Interface "Node FS";
        NewName: Text[120]
    )
    begin
        AccessorExpression := NewAccessorExpression;
        Name := NewName;
    end;

    var
        TopLevel: Boolean;

    procedure SetTopLevel(NewTopLevel: Boolean)
    begin
        TopLevel := NewTopLevel;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        Accessor: Interface "Value FS";
    begin
        Accessor := AccessorExpression.Evaluate(Runtime);
        exit(Accessor.GetProperty(Name));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := AccessorExpression.ValidateSemantics(Runtime, SymbolTable);
        exit(Symbol.LookupProperty(SymbolTable, Name));
    end;

    procedure ValidateSemanticsWithContext
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        ContextSymbol: Record "Symbol FS"
    ): Record "Symbol FS";
    begin
        exit(ValidateSemantics(
            Runtime,
            SymbolTable
        ));
    end;
}