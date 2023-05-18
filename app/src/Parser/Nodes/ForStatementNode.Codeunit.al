codeunit 69020 "For Statement Node FS" implements "Node FS"
{
    var
        Statement: Interface "Node FS";
        IdentifierName: Text[120];
        InitialValueExpression, FinalValueExpression : Interface "Node FS";
        DownToLoop: Boolean;

    procedure Init
    (
        NewStatement: Interface "Node FS";
        NewIdentifierName: Text[120];
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

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        NumericValue: Codeunit "Numeric Value FS";
        InitialValue, ReturnValue : Interface "Value FS";
        Value, FinalValue : Decimal;
    begin
        InitialValue := InitialValueExpression.Evaluate(Runtime);
        Runtime.GetMemory().Set(IdentifierName, InitialValue);
        FinalValue := FinalValueExpression.Evaluate(Runtime).GetValue();

        // TODO rework using the standard for loop?
        Value := Runtime.GetMemory().Get(IdentifierName).GetValue();
        if not CheckCondition(Value, FinalValue) then
            while true do begin
                ReturnValue := Statement.Evaluate(Runtime);
                if ReturnValue.GetType() in [
                    Enum::"Type FS"::"Return Value",
                    Enum::"Type FS"::"Default Return Value"
                ] then
                    exit(ReturnValue);

                // TODO this is not correct, investigate further
                // >>>> when using decimals, end value can different from the final value
                // >>>> maybe check for equality first?
                Value := Increment(Runtime.GetMemory().Get(IdentifierName).GetValue());
                if CheckCondition(Value, FinalValue) then
                    break;

                NumericValue.SetValue(Value);
                Runtime.GetMemory().Set(IdentifierName, NumericValue);
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

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := SymbolTable.Lookup(IdentifierName);
        if Symbol.Type <> Symbol.Type::Number then
            Error('For variable must be of a number type.');

        Symbol := InitialValueExpression.ValidateSemantics(Runtime, SymbolTable);
        if Symbol.Type <> Symbol.Type::Number then
            Error('For initial expression must evaluate to a number type.');

        Symbol := FinalValueExpression.ValidateSemantics(Runtime, SymbolTable);
        if Symbol.Type <> Symbol.Type::Number then
            Error('For final expression must evaluate to a number type.');

        Statement.ValidateSemantics(Runtime, SymbolTable);

        exit(SymbolTable.VoidSymbol());
    end;
}