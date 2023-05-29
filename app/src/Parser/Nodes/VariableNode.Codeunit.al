codeunit 69017 "Variable Node FS" implements "Node FS" // TODO rename to identifier?
{
    var
        Name: Text[120];

    procedure Init(NewName: Text[120])
    begin
        Name := NewName;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Variable");
    end;

    var
        TopLevel: Boolean;

    procedure SetTopLevel(NewTopLevel: Boolean)
    begin
        TopLevel := NewTopLevel;
    end;

    procedure GetName(): Text[120]
    begin
        exit(Name);
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    begin
        exit(Runtime.GetMemory().Get(Name));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    begin
        exit(SymbolTable.Lookup(Name));
    end;

    procedure ValidateSemanticsWithContext
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        ContextSymbol: Record "Symbol FS"
    ): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        // TODO check if name is a prop of ContextSymbol
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