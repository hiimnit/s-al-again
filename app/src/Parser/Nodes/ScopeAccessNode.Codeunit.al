codeunit 69031 "Scope Access Node FS" implements "Node FS"
{
    var
        ScopeExpression: Interface "Node FS";
        ValueIdentifier: Text[120];
        Value: Integer;

    procedure Init
    (
        NewScopeExpression: Interface "Node FS";
        NewValueIdentifier: Text[120]
    )
    begin
        ScopeExpression := NewScopeExpression;
        ValueIdentifier := NewValueIdentifier;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Scope Access");
    end;

    procedure Assignable(): Boolean
    begin
        exit(ScopeExpression.Assignable());
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

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS"
    var
        NewValue: Interface "Value FS";
    begin
        // Copy is important - we do not want to mutate the underlying value, but create a new one
        NewValue := ScopeExpression.Evaluate(Runtime).Copy();
        NewValue.SetValue(Value);
        exit(NewValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        ScopeSymbol: Record "Symbol FS";
    begin
        ScopeSymbol := ScopeExpression.ValidateSemantics(Runtime, SymbolTable);

        Value := ScopeSymbol.ValidateScopeAccess(
            Runtime,
            SymbolTable,
            ScopeSymbol,
            ValueIdentifier
        );

        exit(SymbolTable.IntegerSymbol()); // TODO is this ok?
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