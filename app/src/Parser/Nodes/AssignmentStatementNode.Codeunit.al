codeunit 69018 "Assignment Statement Node FS" implements "Node FS"
{
    var
        Expression: Interface "Node FS";
        Name: Text[120];
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewName: Text[120];
        NewExpression: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        Name := NewName;
        Expression := NewExpression;
        Operator := NewOperator; // TODO check on assignment?
    end;

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        VoidValue: Codeunit "Void Value FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        PreviousValue, NewValue : Interface "Value FS";
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

        NewValue := Expression.Evaluate(Runtime);

        if BinaryOperator <> BinaryOperator::" " then begin
            PreviousValue := Runtime.GetMemory().Get(Name);

            // TODO multiplying strings is going to cause issues
            // >>>> currently it changes the datatype of the variable
            // >>>> should only be allowed one way
            NewValue := BinaryOperatorNode.Evaluate(
                PreviousValue.GetValue(),
                NewValue.GetValue(),
                BinaryOperator
            );
        end;

        Runtime.GetMemory().Set(
            Name,
            NewValue
        );

        exit(VoidValue);
    end;

    procedure ValidateSemantics(SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        VariableSymbol, ExpressionSymbol : Record "Symbol FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        BinaryOperator: Enum "Operator FS";
    begin
        VariableSymbol := SymbolTable.Lookup(Name);

        ExpressionSymbol := Expression.ValidateSemantics(SymbolTable);

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

        if ExpressionSymbol.Type <> VariableSymbol.Type then
            Error('Cannot assign type %1 to variable %2 of type %3.', ExpressionSymbol.Type, Name, VariableSymbol.Type);

        exit(SymbolTable.VoidSymbol());
    end;
}