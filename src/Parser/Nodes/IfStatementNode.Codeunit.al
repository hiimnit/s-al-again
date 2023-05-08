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

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        ExpressionValue: Interface "Value FS";
    begin
        ExpressionValue := Expression.Evaluate(Memory);

        if ExpressionValue.GetValue() then
            IfStatement.Evaluate(Memory)
        else
            if ElseStatementSet then
                ElseStatement.Evaluate(Memory);

        exit(VoidValue);
    end;
}