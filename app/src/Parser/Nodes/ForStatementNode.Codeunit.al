codeunit 69020 "For Statement Node FS" implements "Node FS"
{
    var
        Statement: Interface "Node FS";
        IdentifierName: Text;
        InitialValueExpression, FinalValueExpression : Interface "Node FS";
        DownToLoop: Boolean;

    procedure Init
    (
        NewStatement: Interface "Node FS";
        NewIdentifierName: Text;
        NewInitialValueExpression: Interface "Node FS";
        NewFinalValueExpression: Interface "Node FS";
        NewDownToLoop: Boolean
    )
    begin
        Statement := NewStatement;
        IdentifierName := NewIdentifierName;
        InitialValueExpression := NewInitialValueExpression;
        FinalValueExpression := NewFinalValueExpression;
        DownToLoop := NewDownToLoop;
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        NumericValue: Codeunit "Numeric Value FS";
        InitialValue: Interface "Value FS";
        Value, FinalValue : Decimal;
    begin
        InitialValue := InitialValueExpression.Evaluate(Memory);
        Memory.Set(IdentifierName, InitialValue);
        FinalValue := FinalValueExpression.Evaluate(Memory).GetValue();

        Value := Memory.Get(IdentifierName).GetValue();
        if not CheckCondition(Value, FinalValue) then
            while true do begin
                Statement.Evaluate(Memory);

                // TODO this is not correct, investigate further
                // >>>> when using decimals, end value can different from the final value
                // >>>> maybe check for equality first?
                Value := Increment(Memory.Get(IdentifierName).GetValue());
                if CheckCondition(Value, FinalValue) then
                    break;

                NumericValue.SetValue(Value);
                Memory.Set(IdentifierName, NumericValue);
            end;

        exit(VoidValue);
    end;

    local procedure CheckCondition
    (
        Value: Decimal;
        FinalValue: Decimal
    ): Boolean
    begin
        if DownToLoop then
            exit(Value < FinalValue);
        exit(Value > FinalValue);
    end;

    local procedure Increment(Value: Decimal): Decimal
    begin
        if DownToLoop then
            exit(Value - 1);
        exit(Value + 1);
    end;
}