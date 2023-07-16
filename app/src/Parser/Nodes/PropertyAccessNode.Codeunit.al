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

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Property Access");
    end;

    procedure Assignable(): Boolean
    begin
        // TODO investigate - this used to be `exit(AccessorExpression.Assignable())`
        // but it looks like properties are always assignable?
        exit(true);
    end;

    procedure IsLiteralValue(): Boolean
    begin
        exit(false);
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
    var
        AccessorSymbol, Symbol : Record "Symbol FS";
    begin
        AccessorSymbol := AccessorExpression.ValidateSemantics(Runtime, SymbolTable);
        if (AccessorSymbol.Type = ContextSymbol.Type)
            and (AccessorSymbol.Name.ToLower() = ContextSymbol.Name.ToLower())
        then
            if ContextSymbol.TryLookupProperty(SymbolTable, Name, Symbol) then begin
                Symbol.Name := Name;
                Symbol.Property := true;
                exit(Symbol);
            end;

        exit(ValidateSemantics(
            Runtime,
            SymbolTable
        ));
    end;
}