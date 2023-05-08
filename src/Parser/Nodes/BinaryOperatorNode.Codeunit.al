codeunit 69012 "Binary Operator Node FS" implements "Node FS"
{
    var
        Left, Right : Interface "Node FS";
        BinaryOperator: Enum "Operator FS";

    procedure Init
    (
        NewLeft: Interface "Node FS";
        NewRight: Interface "Node FS";
        NewOperator: Enum "Operator FS"
    )
    begin
        Left := NewLeft;
        Right := NewRight;
        BinaryOperator := NewOperator; // TODO validate?
    end;

    procedure Evaluate(Memory: Codeunit "Memory FS"): Interface "Value FS";
    var
        LeftValueVariant, RightValueVariant : Variant;
    begin
        LeftValueVariant := Left.Evaluate(Memory).GetValue();
        RightValueVariant := Right.Evaluate(Memory).GetValue();

        exit(Evaluate(LeftValueVariant, RightValueVariant, BinaryOperator));
    end;

    procedure Evaluate
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    begin
        case true of
            LeftValueVariant.IsDecimal() and RightValueVariant.IsDecimal():
                exit(EvaluateNumeric(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsBoolean() and RightValueVariant.IsBoolean():
                exit(EvaluateBoolean(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsText() and RightValueVariant.IsText():
                exit(EvaluateText(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsText() and RightValueVariant.IsDecimal(),
            LeftValueVariant.IsDecimal() and RightValueVariant.IsText():
                exit(EvaluateTextMultiplication(LeftValueVariant, RightValueVariant, Operator));
            else
                Error('Unimplemented binary operator input types.'); // TODO
        end;
    end;

    local procedure EvaluateNumeric
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        NumericValue: Codeunit "Numeric Value FS";
        LeftValue, RightValue, Result : Decimal;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"+":
                Result := LeftValue + RightValue;
            Operator::"-":
                Result := LeftValue - RightValue;
            Operator::"*":
                Result := LeftValue * RightValue;
            Operator::"/":
                Result := LeftValue / RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        NumericValue.SetValue(Result);
        exit(NumericValue);
    end;

    local procedure EvaluateBoolean
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        BooleanValue: Codeunit "Boolean Value FS";
        LeftValue, RightValue, Result : Boolean;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"or":
                Result := LeftValue or RightValue;
            Operator::"and":
                Result := LeftValue and RightValue;
            Operator::"xor":
                Result := LeftValue xor RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        BooleanValue.SetValue(Result);
        exit(BooleanValue);
    end;

    local procedure EvaluateText
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        TextValue: Codeunit "Text Value FS";
        LeftValue, RightValue, Result : Text;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"+":
                Result := LeftValue + RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        TextValue.SetValue(Result);
        exit(TextValue);
    end;

    local procedure EvaluateTextMultiplication
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        TextValue: Codeunit "Text Value FS";
        Text: Text;
        Number: Decimal;
        i: Integer;
        ResultBuilder: TextBuilder;
    begin
        case true of
            LeftValueVariant.IsText() and RightValueVariant.IsDecimal():
                begin
                    Text := LeftValueVariant;
                    Number := RightValueVariant;
                end;
            LeftValueVariant.IsDecimal() and RightValueVariant.IsText():
                begin
                    Number := LeftValueVariant;
                    Text := RightValueVariant;
                end;
            else
                Error('Invalid argument types.');
        end;


        case Operator of
            Operator::"*":
                // TODO check negative number?
                for i := 1 to Number do
                    ResultBuilder.Append(Text);
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        TextValue.SetValue(ResultBuilder.ToText());
        exit(TextValue);
    end;
}