codeunit 69021 "While Statement Node FS" implements "Node FS"
{
    var
        Statement: Interface "Node FS";
        Expression: Interface "Node FS";

    procedure Init
    (
        NewStatement: Interface "Node FS";
        NewExpression: Interface "Node FS"
    )
    begin
        Statement := NewStatement;
        Expression := NewExpression;
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        Value: Interface "Value FS";
    begin
        while true do begin
            Value := Expression.Evaluate(Memory);
            if not Value.GetValue() then
                break;

            Statement.Evaluate(Memory);
        end;

        exit(VoidValue);
    end;
}