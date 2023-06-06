codeunit 69019 "If Statement Node FS" implements "Node FS"
{
    var
        Expression, IfStatement, ElseStatement : Interface "Node FS";
        ElseStatementSet: Boolean;

    procedure InitIf
    (
        NewExpression: Interface "Node FS";
        NewIfStatement: Interface "Node FS"
    )
    begin
        Expression := NewExpression;
        IfStatement := NewIfStatement;
    end;

    procedure InitElse
    (
        NewElseStatement: Interface "Node FS"
    )
    begin
        ElseStatement := NewElseStatement;
        ElseStatementSet := true;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"If Statement");
    end;

    procedure Assignable(): Boolean
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
        VoidValue: Codeunit "Void Value FS";
        ExpressionValue: Interface "Value FS";
    begin
        ExpressionValue := Expression.Evaluate(Runtime);

        if ExpressionValue.GetValue() then
            exit(IfStatement.Evaluate(Runtime));

        if ElseStatementSet then
            exit(ElseStatement.Evaluate(Runtime));

        exit(VoidValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := Expression.ValidateSemantics(Runtime, SymbolTable);
        if Symbol.Type <> Symbol.Type::Boolean then
            Error('If condition must evaluate to a boolean value.');

        IfStatement.ValidateSemantics(Runtime, SymbolTable);
        if ElseStatementSet then
            ElseStatement.ValidateSemantics(Runtime, SymbolTable);

        exit(SymbolTable.VoidSymbol());
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