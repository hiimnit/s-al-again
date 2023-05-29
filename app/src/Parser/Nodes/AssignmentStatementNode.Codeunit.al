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

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        VariableSymbol, ExpressionSymbol : Record "Symbol FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        BinaryOperator: Enum "Operator FS";
    begin
        VariableSymbol := SymbolTable.Lookup(Name);

        ExpressionSymbol := Expression.ValidateSemantics(Runtime, SymbolTable);

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