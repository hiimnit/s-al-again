codeunit 69029 "Index Access Node FS" implements "Node FS"
{
    var
        ValueExpression, IndexExpression : Interface "Node FS";

    procedure Init
    (
        NewValueExpression: Interface "Node FS";
        NewIndexExpression: Interface "Node FS"
    )
    begin
        ValueExpression := NewValueExpression;
        IndexExpression := NewIndexExpression;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Index Access");
    end;

    var
        TopLevel: Boolean;

    procedure SetTopLevel(NewTopLevel: Boolean)
    begin
        TopLevel := NewTopLevel;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS"
    var
        Value, Index : Interface "Value FS";
    begin
        Value := ValueExpression.Evaluate(Runtime);
        Index := IndexExpression.Evaluate(Runtime);

        exit(Value.At(Index));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        ValueSymbol, IndexSymbol : Record "Symbol FS";
    begin
        ValueSymbol := ValueExpression.ValidateSemantics(Runtime, SymbolTable);
        IndexSymbol := IndexExpression.ValidateSemantics(Runtime, SymbolTable);

        exit(ValueSymbol.ValidateIndexAcces(
            Runtime,
            SymbolTable,
            ValueSymbol,
            IndexSymbol
        ));
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