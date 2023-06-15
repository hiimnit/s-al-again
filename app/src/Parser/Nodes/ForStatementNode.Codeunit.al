codeunit 69020 "For Statement Node FS" implements "Node FS"
{
    var
        Statement: Interface "Node FS";
        VariableExpression, InitialValueExpression, FinalValueExpression : Interface "Node FS";
        DownToLoop: Boolean;

    procedure Init
    (
        NewStatement: Interface "Node FS";
        NewVariableExpression: Interface "Node FS";
        NewInitialValueExpression: Interface "Node FS";
        NewFinalValueExpression: Interface "Node FS";
        NewDownToLoop: Boolean
    )
    begin
        Statement := NewStatement;
        VariableExpression := NewVariableExpression;
        InitialValueExpression := NewInitialValueExpression;
        FinalValueExpression := NewFinalValueExpression;
        DownToLoop := NewDownToLoop;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"For Statement");
    end;

    procedure Assignable(): Boolean
    begin
        exit(false);
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

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        VariableValue, InitialValue : Interface "Value FS";
        Value, FinalValue : Decimal;
    begin
        VariableValue := VariableExpression.Evaluate(Runtime);
        InitialValue := InitialValueExpression.Evaluate(Runtime);
        VariableValue.Mutate(InitialValue);

        FinalValue := FinalValueExpression.Evaluate(Runtime).GetValue();

        while not CheckCondition(Value, FinalValue) do begin
            Statement.Evaluate(Runtime);
            if Runtime.IsExited() then
                exit(VoidValue);

            // when using decimals, end value can different from the final value
            // unless they are equal
            if Value = FinalValue then
                break;

            VariableValue := VariableExpression.Evaluate(Runtime);
            Value := Increment(VariableValue.GetValue());
            VariableValue.SetValue(Value);
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
        Symbol, VariableSymbol : Record "Symbol FS";
    begin
        if not VariableExpression.Assignable() then
            Error('Left side of for statement assignment must be an assignable variable.');

        VariableSymbol := VariableExpression.ValidateSemantics(Runtime, SymbolTable);
        if not Runtime.MatchTypesCoercible(
            SymbolTable.DecimalSymbol(),
            VariableSymbol
        ) then
            Error('For statement variable must be of a number type.');

        Symbol := InitialValueExpression.ValidateSemantics(Runtime, SymbolTable);
        if not Runtime.MatchTypesCoercible(
            VariableSymbol,
            Symbol
        ) then
            Error('For statement initial expression must evaluate to a number type.');

        Symbol := FinalValueExpression.ValidateSemantics(Runtime, SymbolTable);
        if not Runtime.MatchTypesCoercible(
            VariableSymbol,
            Symbol
        ) then
            Error('For final expression must evaluate to a number type.');

        Statement.ValidateSemantics(Runtime, SymbolTable);

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