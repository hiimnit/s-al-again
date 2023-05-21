codeunit 69027 "Set Statement Node FS" implements "Node FS"
{
    var
        AccesorExpression, ValueExpression : Interface "Node FS";
        Name: Text[120];
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewAccesorExpression: Interface "Node FS";
        NewName: Text[120];
        NewValueExpression: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        AccesorExpression := NewAccesorExpression;
        Name := NewName;
        ValueExpression := NewValueExpression;
        Operator := NewOperator;
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
        AccessorValue, PreviousValue, NewValue : Interface "Value FS";
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

        AccessorValue := AccesorExpression.Evaluate(Runtime);
        NewValue := ValueExpression.Evaluate(Runtime);

        if BinaryOperator <> BinaryOperator::" " then begin
            PreviousValue := AccessorValue.GetProperty(Name);

            NewValue := BinaryOperatorNode.Evaluate(
                PreviousValue.GetValue(),
                NewValue.GetValue(),
                BinaryOperator
            );
        end;

        AccessorValue.SetProperty(Name, NewValue);

        exit(VoidValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        VariableSymbol, AccesorExpressionSymbol, ValueExpressionSymbol : Record "Symbol FS";
        BinaryOperatorNode: Codeunit "Binary Operator Node FS";
        BinaryOperator: Enum "Operator FS";
    begin
        AccesorExpressionSymbol := AccesorExpression.ValidateSemantics(Runtime, SymbolTable);
        VariableSymbol := AccesorExpressionSymbol.LookupProperty(SymbolTable, Name);

        ValueExpressionSymbol := ValueExpression.ValidateSemantics(Runtime, SymbolTable);

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
            ValueExpressionSymbol := BinaryOperatorNode.ValidateSemantics(
                SymbolTable,
                VariableSymbol,
                ValueExpressionSymbol,
                BinaryOperator
            );

        if ValueExpressionSymbol.Type <> VariableSymbol.Type then
            Error('Cannot assign type %1 to variable %2 of type %3.', ValueExpressionSymbol.Type, Name, VariableSymbol.Type);

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