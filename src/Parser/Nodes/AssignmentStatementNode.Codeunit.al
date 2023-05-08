codeunit 69018 "Assignment Statement Node FS" implements "Node FS"
{
    var
        Expression: Interface "Node FS";
        Name: Text;

    procedure Init
    (
        NewName: Text;
        NewExpression: Interface "Node FS"
    )
    begin
        Name := NewName;
        Expression := NewExpression;
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
    begin
        Memory.Set(
            Name,
            Expression.Evaluate(Memory)
        );

        exit(VoidValue);
    end;
}