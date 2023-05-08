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
        Operator := NewOperator; // TODO validate?
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        ValueVariant: Variant;
    begin
        ValueVariant := Node.Evaluate(Memory).GetValue();

        case Operator of
            Operator::"+",
            Operator::"-":
                exit(EvaluateNumeric(ValueVariant));
            Operator::"not":
                exit(EvaluateBoolean(ValueVariant));
            else
                Error('Unimplemented unary operator %1.', Operator); // TODO
        end;
    end;

    local procedure EvaluateNumeric(ValueVariant: Variant): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        Value, Result : Decimal;
    begin
        Value := ValueVariant; // TODO runtime type checking?

        case Operator of
            Operator::"+":
                Result := Value;
            Operator::"-":
                Result := -Value;
            else
                Error('Unimplemented unary operator %1.', Operator); // TODO
        end;

        NumericValue.SetValue(Result);
        exit(NumericValue);
    end;

    local procedure EvaluateBoolean(ValueVariant: Variant): Interface "Value FS";
    var
        BooleanValue: Codeunit "Boolean Value FS";
        Value, Result : Boolean;
    begin
        Value := ValueVariant; // TODO runtime type checking?

        case Operator of
            Operator::"not":
                Result := not Value;
            else
                Error('Unimplemented unary operator %1.', Operator); // TODO
        end;

        BooleanValue.SetValue(Result);
        exit(BooleanValue);
    end;
}