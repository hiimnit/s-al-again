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

    procedure Evaluate(Runtime: Codeunit "Runtime FS"): Interface "Value FS";
    var
        LeftValueVariant, RightValueVariant : Variant;
    begin
        LeftValueVariant := Left.Evaluate(Runtime).GetValue();
        RightValueVariant := Right.Evaluate(Runtime).GetValue();

        exit(Evaluate(LeftValueVariant, RightValueVariant, BinaryOperator));
    end;

    procedure Evaluate
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    begin
        case Operator of
            Operator::"<",
            Operator::"<=",
            Operator::"<>",
            Operator::">=",
            Operator::">",
            Operator::"=":
                exit(EvaluateComparison(LeftValueVariant, RightValueVariant, Operator));
        end;

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
            Operator::"div":
                Result := LeftValue div RightValue;
            Operator::"mod":
                Result := LeftValue mod RightValue;
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
                begin
                    if Number < 1 then
                        Error('Invalid text multiplication input - cannot multiply by %1.', Number);
                    for i := 1 to Number do
                        ResultBuilder.Append(Text);
                end;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        TextValue.SetValue(ResultBuilder.ToText());
        exit(TextValue);
    end;

    local procedure EvaluateComparison
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        BooleanValue: Codeunit "Boolean Value FS";
        Result: Boolean;
    begin
        case true of
            LeftValueVariant.IsText() and RightValueVariant.IsText():
                Result := CompareText(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsDecimal() and RightValueVariant.IsDecimal():
                Result := CompareNumber(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsBoolean() and RightValueVariant.IsBoolean():
                Result := CompareBoolean(LeftValueVariant, RightValueVariant, Operator);
            else
                Error('Comparison between types is not implemented'); // TODO nicer error?
        end;

        BooleanValue.SetValue(Result);
        exit(BooleanValue);
    end;

    local procedure CompareText
    (
        LeftValue: Text;
        RightValue: Text;
        Operator: Enum "Operator FS"
    ): Boolean
    begin
        case Operator of
            Operator::"<":
                exit(LeftValue < RightValue);
            Operator::"<=":
                exit(LeftValue <= RightValue);
            Operator::"<>":
                exit(LeftValue <> RightValue);
            Operator::">=":
                exit(LeftValue >= RightValue);
            Operator::">":
                exit(LeftValue > RightValue);
            Operator::"=":
                exit(LeftValue = RightValue);
            else
                Error('Unexpected comparison operator %1.', Operator);
        end;
    end;

    local procedure CompareNumber
    (
        LeftValue: Decimal;
        RightValue: Decimal;
        Operator: Enum "Operator FS"
    ): Boolean
    begin
        case Operator of
            Operator::"<":
                exit(LeftValue < RightValue);
            Operator::"<=":
                exit(LeftValue <= RightValue);
            Operator::"<>":
                exit(LeftValue <> RightValue);
            Operator::">=":
                exit(LeftValue >= RightValue);
            Operator::">":
                exit(LeftValue > RightValue);
            Operator::"=":
                exit(LeftValue = RightValue);
            else
                Error('Unexpected comparison operator %1.', Operator);
        end;
    end;

    local procedure CompareBoolean
    (
        LeftValue: Boolean;
        RightValue: Boolean;
        Operator: Enum "Operator FS"
    ): Boolean
    begin
        case Operator of
            Operator::"<":
                exit(LeftValue < RightValue);
            Operator::"<=":
                exit(LeftValue <= RightValue);
            Operator::"<>":
                exit(LeftValue <> RightValue);
            Operator::">=":
                exit(LeftValue >= RightValue);
            Operator::">":
                exit(LeftValue > RightValue);
            Operator::"=":
                exit(LeftValue = RightValue);
            else
                Error('Unexpected comparison operator %1.', Operator);
        end;
    end;

    procedure ValidateSemantics(Runtime: Codeunit "Runtime FS"; SymbolTable: Codeunit "Symbol Table FS"): Record "Symbol FS";
    var
        LeftSymbol, RightSymbol : Record "Symbol FS";
    begin
        LeftSymbol := Left.ValidateSemantics(Runtime, SymbolTable);
        RightSymbol := Right.ValidateSemantics(Runtime, SymbolTable);

        exit(ValidateSemantics(
            SymbolTable,
            LeftSymbol,
            RightSymbol,
            BinaryOperator
        ));
    end;

    procedure ValidateSemantics
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS";
    var
        ResultSymbol: Record "Symbol FS";
    begin
        case true of
            Operator in [
                Operator::"<",
                Operator::"<=",
                Operator::"<>",
                Operator::">=",
                Operator::">",
                Operator::"="
            ]:
                ResultSymbol := ValidateComparison(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            (LeftSymbol.Type = LeftSymbol.Type::Number) and (RightSymbol.Type = RightSymbol.Type::Number):
                ResultSymbol := ValidateNumeric(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            (LeftSymbol.Type = LeftSymbol.Type::Boolean) and (RightSymbol.Type = RightSymbol.Type::Boolean):
                ResultSymbol := ValidateBoolean(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Text):
                ResultSymbol := ValidateText(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Number),
            (LeftSymbol.Type = LeftSymbol.Type::Number) and (RightSymbol.Type = RightSymbol.Type::Text):
                ResultSymbol := ValidateTextMultiplication(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(ResultSymbol);
    end;

    local procedure ValidateComparison
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        case true of
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Text),
            (LeftSymbol.Type = LeftSymbol.Type::Number) and (RightSymbol.Type = RightSymbol.Type::Number),
            (LeftSymbol.Type = LeftSymbol.Type::Boolean) and (RightSymbol.Type = RightSymbol.Type::Boolean):
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.BooleanSymbol());
    end;

    local procedure ValidateNumeric
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        case Operator of
            Operator::"+",
            Operator::"-",
            Operator::"*",
            Operator::"/",
            Operator::"div",
            Operator::"mod":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.NumericSymbol());
    end;

    local procedure ValidateBoolean
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        case Operator of
            Operator::"or",
            Operator::"and",
            Operator::"xor":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.BooleanSymbol());
    end;

    local procedure ValidateText
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        case Operator of
            Operator::"+":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.TextSymbol());
    end;

    local procedure ValidateTextMultiplication
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        case Operator of
            Operator::"*":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.TextSymbol());
    end;
}