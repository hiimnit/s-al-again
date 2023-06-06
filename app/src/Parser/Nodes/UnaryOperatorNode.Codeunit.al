codeunit 69013 "Unary Operator Node FS" implements "Node FS"
{
    var
        Node: Interface "Node FS";
        Operator: Enum "Operator FS";

    procedure Init
    (
        NewNode: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        Node := NewNode;
        Operator := NewOperator;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Unary Operator");
    end;

    procedure Assignable(): Boolean
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
        ValueVariant: Variant;
    begin
        ValueVariant := Node.Evaluate(Runtime).GetValue();

        case Operator of
            Operator::"+",
            Operator::"-":
                exit(EvaluateNumeric(ValueVariant));
            Operator::"not":
                exit(EvaluateBoolean(ValueVariant));
            else
                Error('Unimplemented unary operator %1.', Operator);
        end;
    end;

    local procedure EvaluateNumeric(ValueVariant: Variant): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        Value, Result : Decimal;
    begin
        Value := ValueVariant;

        case Operator of
            Operator::"+":
                Result := Value;
            Operator::"-":
                Result := -Value;
            else
                Error('Unimplemented unary operator %1.', Operator);
        end;

        NumericValue.SetValue(Result);
        exit(NumericValue);
    end;

    local procedure EvaluateBoolean(ValueVariant: Variant): Interface "Value FS";
    var
        BooleanValue: Codeunit "Boolean Value FS";
        Value, Result : Boolean;
    begin
        Value := ValueVariant;

        case Operator of
            Operator::"not":
                Result := not Value;
            else
                Error('Unimplemented unary operator %1.', Operator);
        end;

        BooleanValue.SetValue(Result);
        exit(BooleanValue);
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        Symbol: Record "Symbol FS";
    begin
        Symbol := Node.ValidateSemantics(Runtime, SymbolTable);

        case Operator of
            Operator::"+",
            Operator::"-":
                if Symbol.Type <> Symbol.Type::Number then
                    Error('Unary operator %1 can not be applied to symbol %2.', Operator, Symbol.Type);
            Operator::"not":
                if Symbol.Type <> Symbol.Type::Boolean then
                    Error('Unary operator %1 can not be applied to symbol %2.', Operator, Symbol.Type);
            else
                Error('Unimplemented unary operator %1.', Operator);
        end;

        exit(Symbol);
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