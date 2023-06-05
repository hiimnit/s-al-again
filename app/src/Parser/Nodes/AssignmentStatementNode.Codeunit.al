codeunit 69018 "Assignment Statement Node FS" implements "Node FS"
{
    var
        VariableExpression, ValueExpression : Interface "Node FS";
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewVariableExpression: Interface "Node FS";
        NewValueExpression: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        VariableExpression := NewVariableExpression;
        ValueExpression := NewValueExpression;
        Operator := NewOperator;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Assignment Statement");
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
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        VariableValue, NewValue : Interface "Value FS";
        BinaryOperator: Enum "Operator FS";
    begin
        case Operator of
            Operator::"+=":
                BinaryOperator := BinaryOperator::"+";
            Operator::"-=":
                BinaryOperator := BinaryOperator::"-";
            Operator::"*=":
                BinaryOperator := BinaryOperator::"*";
            Operator::"/=":
                BinaryOperator := BinaryOperator::"/";
            Operator::":=":
                BinaryOperator := BinaryOperator::" ";
            else
                Error('Unimplemented assignment operator %1.', Operator);
        end;

        NewValue := ValueExpression.Evaluate(Runtime);
        VariableValue := VariableExpression.Evaluate(Runtime);

        if BinaryOperator <> BinaryOperator::" " then
            NewValue := BinaryOperatorNode.Evaluate(
                VariableValue.GetValue(),
                NewValue.GetValue(),
                BinaryOperator
            );

        VariableValue.Mutate(NewValue);

        exit(VoidValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        VariableSymbol, ExpressionSymbol : Record "Symbol FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        BinaryOperator: Enum "Operator FS";
    begin
        if VariableExpression.GetType() <> Enum::"Node Type FS"::Variable then
            // TODO incomplete list - variables, fields + index access (to variables/fields?)
            Error('Left side of assignment must be a variable.');

        VariableSymbol := VariableExpression.ValidateSemantics(Runtime, SymbolTable);
        ExpressionSymbol := ValueExpression.ValidateSemantics(Runtime, SymbolTable);

        case Operator of
            Operator::"+=":
                BinaryOperator := BinaryOperator::"+";
            Operator::"-=":
                BinaryOperator := BinaryOperator::"-";
            Operator::"*=":
                BinaryOperator := BinaryOperator::"*";
            Operator::"/=":
                BinaryOperator := BinaryOperator::"/";
            Operator::":=":
                BinaryOperator := BinaryOperator::" ";
            else
                Error('Unimplemented assignment operator %1.', Operator);
        end;

        if BinaryOperator <> BinaryOperator::" " then
            ExpressionSymbol := BinaryOperatorNode.ValidateSemantics(
                SymbolTable,
                VariableSymbol,
                ExpressionSymbol,
                BinaryOperator
            );

        if not Runtime.MatchTypesCoercible(VariableSymbol, ExpressionSymbol) then
            Error('Cannot assign type %1 to variable of type %2.', ExpressionSymbol.Type, VariableSymbol.Type);

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