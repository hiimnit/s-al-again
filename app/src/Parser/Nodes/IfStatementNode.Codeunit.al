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

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        ExpressionValue, Value : Interface "Value FS";
    begin
        ExpressionValue := Expression.Evaluate(Runtime);

        if ExpressionValue.GetValue() then
            Value := IfStatement.Evaluate(Runtime)
        else
            if ElseStatementSet then
                Value := ElseStatement.Evaluate(Runtime);

        exit(Value);
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
}