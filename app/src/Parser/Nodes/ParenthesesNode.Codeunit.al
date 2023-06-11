codeunit 69030 "Parentheses Node FS" implements "Node FS"
{
    var
        Expression: Interface "Node FS";

    procedure Init
    (
        NewExpression: Interface "Node FS"
    )
    begin
        Expression := NewExpression;
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS"
    begin
        exit(Expression.Evaluate(Runtime));
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS"
    begin
        exit(Expression.ValidateSemantics(Runtime, SymbolTable));
    end;

    procedure ValidateSemanticsWithContext
    (
        Runtime: Codeunit "Runtime FS";
        SymbolTable: Codeunit "Symbol Table FS";
        ContextSymbol: Record "Symbol FS"
    ): Record "Symbol FS"
    begin
        exit(ValidateSemantics(Runtime, SymbolTable));
    end;

    var
        TopLevel: Boolean;

    procedure SetTopLevel(NewTopLevel: Boolean)
    begin
        TopLevel := NewTopLevel;
    end;

    procedure GetType(): Enum "Node Type FS"
    begin
        exit(Enum::"Node Type FS"::"Parentheses Node");
    end;

    procedure Assignable(): Boolean
    begin
        exit(false);
    end;

    procedure IsLiteralValue(): Boolean
    begin
        exit(false);
    end;
}