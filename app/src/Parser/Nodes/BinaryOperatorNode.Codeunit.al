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
        BinaryOperator := NewOperator;
    end;

    procedure GetType(): Enum "Node Type FS";
    begin
        exit(Enum::"Node Type FS"::"Binary Operator");
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
        LeftValueVariant, RightValueVariant : Variant;
    begin
        LeftValueVariant := Left.Evaluate(Runtime).GetValue();
        RightValueVariant := Right.Evaluate(Runtime).GetValue();

        exit(Evaluate(
            LeftValueVariant,
            RightValueVariant,
            BinaryOperator,
            Left.IsLiteralValue(),
            Right.IsLiteralValue()
        ));
    end;

    procedure Evaluate
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS";
        LeftIsLiteral: Boolean;
        RightIsLiteral: Boolean
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
            LeftValueVariant.IsChar() and RightValueVariant.IsChar():
                exit(EvaluateChar(
                    LeftValueVariant,
                    RightValueVariant,
                    Operator,
                    LeftIsLiteral,
                    RightIsLiteral
                ));
            IsNumeric(LeftValueVariant) and IsNumeric(RightValueVariant):
                exit(EvaluateNumeric(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsBoolean() and RightValueVariant.IsBoolean():
                exit(EvaluateBoolean(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsText() and RightValueVariant.IsText(),
            LeftValueVariant.IsGuid() and RightValueVariant.IsText(),
            LeftValueVariant.IsText() and RightValueVariant.IsGuid(),
            LeftValueVariant.IsGuid() and RightValueVariant.IsGuid():
                exit(EvaluateText(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsText() and RightValueVariant.IsDecimal(),
            LeftValueVariant.IsGuid() and RightValueVariant.IsDecimal():
                exit(EvaluateTextMultiplication(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsDecimal() and RightValueVariant.IsText(),
            LeftValueVariant.IsDecimal() and RightValueVariant.IsGuid():
                exit(EvaluateTextMultiplication(RightValueVariant, LeftValueVariant, Operator));
            LeftValueVariant.IsDate() and RightValueVariant.IsDate():
                exit(EvaluateDate(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsTime() and RightValueVariant.IsTime():
                exit(EvaluateTime(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsDateTime() and RightValueVariant.IsDateTime():
                exit(EvaluateDateTime(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsDate() and RightValueVariant.IsDecimal():
                exit(EvaluateDateNumber(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsDecimal() and RightValueVariant.IsDate():
                exit(EvaluateDateNumber(RightValueVariant, LeftValueVariant, Operator));
            LeftValueVariant.IsTime() and RightValueVariant.IsDecimal():
                exit(EvaluateTimeNumber(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsDecimal() and RightValueVariant.IsTime():
                exit(EvaluateTimeNumber(RightValueVariant, LeftValueVariant, Operator));
            LeftValueVariant.IsDateTime() and RightValueVariant.IsDecimal():
                exit(EvaluateDateTimeNumber(LeftValueVariant, RightValueVariant, Operator));
            LeftValueVariant.IsDecimal() and RightValueVariant.IsDateTime():
                exit(EvaluateDateTimeNumber(RightValueVariant, LeftValueVariant, Operator));
            else
                Error('Unimplemented binary operator input types.'); // TODO nicer error?
        end;
    end;

    local procedure EvaluateNumeric
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    begin
        if LeftValueVariant.IsDecimal() or RightValueVariant.IsDecimal() then
            exit(EvaluateDecimal(
                LeftValueVariant,
                RightValueVariant,
                Operator
            ));

        exit(EvaluateIntegerInteger(
            LeftValueVariant,
            RightValueVariant,
            Operator
        ));
    end;

    local procedure EvaluateIntegerInteger
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        IntegerValue: Codeunit "Integer Value FS";
        DecimalValue: Codeunit "Decimal Value FS";
        LeftValue, RightValue, Result : Integer;
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
                begin
                    DecimalValue.SetValue(LeftValue / RightValue);
                    exit(DecimalValue);
                end;
            Operator::"div":
                Result := LeftValue div RightValue;
            Operator::"mod":
                Result := LeftValue mod RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        IntegerValue.SetValue(Result);
        exit(IntegerValue);
    end;

    local procedure EvaluateDecimal
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        DecimalValue: Codeunit "Decimal Value FS";
        LeftValue, RightValue, Result : Decimal;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        if not RightValueVariant.IsDecimal()
            and (Operator in [Operator::"div", Operator::"mod"])
        then
            exit(EvaluateDecimalToInteger(
                LeftValueVariant,
                RightValueVariant,
                Operator
            ));

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

        DecimalValue.SetValue(Result);
        exit(DecimalValue);
    end;

    local procedure EvaluateDecimalToInteger
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS"
    var
        IntegerValue: Codeunit "Integer Value FS";
        LeftValue: Decimal;
        RightValue, Result : Integer;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"div":
                Result := LeftValue div RightValue;
            Operator::"mod":
                Result := LeftValue mod RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        IntegerValue.SetValue(Result);
        exit(IntegerValue);
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
        Text := LeftValueVariant;
        Number := RightValueVariant;

        case Operator of
            Operator::"*":
                begin
                    if Number < 1 then // XXX allow 0?
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

    local procedure EvaluateDate
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        IntegerValue: Codeunit "Integer Value FS";
        LeftValue, RightValue : Date;
        Result: Integer;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"-":
                Result := LeftValue - RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        IntegerValue.SetValue(Result);
        exit(IntegerValue);
    end;

    local procedure EvaluateTime
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        IntegerValue: Codeunit "Integer Value FS";
        LeftValue, RightValue : Time;
        Result: Integer;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"-":
                Result := LeftValue - RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        IntegerValue.SetValue(Result);
        exit(IntegerValue);
    end;

    local procedure EvaluateDateTime
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        IntegerValue: Codeunit "Integer Value FS";
        LeftValue, RightValue : DateTime;
        Result: Integer;
    begin
        LeftValue := LeftValueVariant;
        RightValue := RightValueVariant;

        case Operator of
            Operator::"-":
                // TODO should result in a duration value
                Result := LeftValue - RightValue;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        IntegerValue.SetValue(Result);
        exit(IntegerValue);
    end;

    local procedure EvaluateDateNumber
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        DateValue: Codeunit "Date Value FS";
        Date, Result : Date;
        Number: Decimal;
    begin
        Date := LeftValueVariant;
        Number := RightValueVariant;

        case Operator of
            Operator::"+":
                Result := Date + Number;
            Operator::"-":
                Result := Date - Number;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        DateValue.SetValue(Result);
        exit(DateValue);
    end;

    local procedure EvaluateTimeNumber
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        TimeValue: Codeunit "Time Value FS";
        Time, Result : Time;
        Number: Decimal;
    begin
        Time := LeftValueVariant;
        Number := RightValueVariant;

        case Operator of
            Operator::"+":
                Result := Time + Number;
            Operator::"-":
                Result := Time - Number;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        TimeValue.SetValue(Result);
        exit(TimeValue);
    end;

    local procedure EvaluateDateTimeNumber
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS"
    ): Interface "Value FS";
    var
        DateTimeValue: Codeunit "DateTime Value FS";
        DateTime, Result : DateTime;
        Number: Decimal;
    begin
        DateTime := LeftValueVariant;
        Number := RightValueVariant;

        case Operator of
            Operator::"+":
                Result := DateTime + Number;
            Operator::"-":
                Result := DateTime - Number;
            else
                Error('Unimplemented binary operator %1.', Operator);
        end;

        DateTimeValue.SetValue(Result);
        exit(DateTimeValue);
    end;

    local procedure EvaluateChar
    (
        LeftValueVariant: Variant;
        RightValueVariant: Variant;
        Operator: Enum "Operator FS";
        LeftIsLiteral: Boolean;
        RightIsLiteral: Boolean
    ): Interface "Value FS";
    var
        TextValue: Codeunit "Text Value FS";
        LeftValue, RightValue : Char;
        Result: Text;
    begin
        if LeftIsLiteral and RightIsLiteral then begin
            LeftValue := LeftValueVariant;
            RightValue := RightValueVariant;

            case Operator of
                Operator::"+":
                    Result := Format(LeftValue) + Format(RightValue);
                else
                    Error('Unimplemented binary operator %1.', Operator);
            end;

            TextValue.SetValue(Result);
            exit(TextValue);
        end;

        exit(EvaluateNumeric(
            LeftValueVariant,
            RightValueVariant,
            Operator
        ));
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
            LeftValueVariant.IsText() and RightValueVariant.IsText(),
            LeftValueVariant.IsText() and RightValueVariant.IsGuid(),
            LeftValueVariant.IsGuid() and RightValueVariant.IsText(),
            LeftValueVariant.IsGuid() and RightValueVariant.IsGuid(),
            LeftValueVariant.IsChar() and RightValueVariant.IsChar(),
            LeftValueVariant.IsChar() and RightValueVariant.IsText(),
            LeftValueVariant.IsText() and RightValueVariant.IsChar():
                Result := CompareText(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsChar() and RightValueVariant.IsDecimal():
                Result := CompareCharNumber(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsDecimal() and RightValueVariant.IsChar():
                Result := CompareCharNumber(RightValueVariant, LeftValueVariant, Operator);
            LeftValueVariant.IsDecimal() and RightValueVariant.IsDecimal():
                Result := CompareNumber(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsBoolean() and RightValueVariant.IsBoolean():
                Result := CompareBoolean(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsDate() and RightValueVariant.IsDate():
                Result := CompareDate(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsTime() and RightValueVariant.IsTime():
                Result := CompareTime(LeftValueVariant, RightValueVariant, Operator);
            LeftValueVariant.IsDateTime() and RightValueVariant.IsDateTime():
                Result := CompareDateTime(LeftValueVariant, RightValueVariant, Operator);
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

    local procedure CompareDate
    (
        LeftValue: Date;
        RightValue: Date;
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

    local procedure CompareTime
    (
        LeftValue: Time;
        RightValue: Time;
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

    local procedure CompareDateTime
    (
        LeftValue: DateTime;
        RightValue: DateTime;
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

    local procedure CompareCharNumber
    (
        LeftValue: Char;
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
            BinaryOperator,
            Left.IsLiteralValue(),
            Right.IsLiteralValue()
        ));
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

    procedure ValidateSemantics
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS";
        LeftIsLiteral: Boolean;
        RightIsLiteral: Boolean
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
            (LeftSymbol.Type = LeftSymbol.Type::Char) and (RightSymbol.Type = RightSymbol.Type::Char):
                ResultSymbol := ValidateChar(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator,
                    LeftIsLiteral,
                    RightIsLiteral
                );
            IsNumeric(LeftSymbol) and IsNumeric(RightSymbol):
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
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Text),
            (LeftSymbol.Type = LeftSymbol.Type::Guid) and (RightSymbol.Type = RightSymbol.Type::Text),
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Guid),
            (LeftSymbol.Type = LeftSymbol.Type::Guid) and (RightSymbol.Type = RightSymbol.Type::Guid),
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Char),
            (LeftSymbol.Type = LeftSymbol.Type::Char) and (RightSymbol.Type = RightSymbol.Type::Text):
                ResultSymbol := ValidateText(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            // TODO integer only here? // FIXME
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Integer),
            (LeftSymbol.Type = LeftSymbol.Type::Integer) and (RightSymbol.Type = RightSymbol.Type::Text),
            (LeftSymbol.Type = LeftSymbol.Type::Guid) and (RightSymbol.Type = RightSymbol.Type::Integer),
            (LeftSymbol.Type = LeftSymbol.Type::Integer) and (RightSymbol.Type = RightSymbol.Type::Guid):
                ResultSymbol := ValidateTextMultiplication(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            (LeftSymbol.Type = LeftSymbol.Type::Date) and (RightSymbol.Type = RightSymbol.Type::Date),
            (LeftSymbol.Type = LeftSymbol.Type::Time) and (RightSymbol.Type = RightSymbol.Type::Time),
            (LeftSymbol.Type = LeftSymbol.Type::DateTime) and (RightSymbol.Type = RightSymbol.Type::DateTime):
                ResultSymbol := ValidateDateTime(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            IsNumeric(LeftSymbol) and (RightSymbol.Type = RightSymbol.Type::Date),
            (LeftSymbol.Type = LeftSymbol.Type::Date) and IsNumeric(RightSymbol):
                ResultSymbol := ValidateDateNumber(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            IsNumeric(LeftSymbol) and (RightSymbol.Type = RightSymbol.Type::Time),
            (LeftSymbol.Type = LeftSymbol.Type::Time) and IsNumeric(RightSymbol):
                ResultSymbol := ValidateTimeNumber(
                    SymbolTable,
                    LeftSymbol,
                    RightSymbol,
                    Operator
                );
            IsNumeric(LeftSymbol) and (RightSymbol.Type = RightSymbol.Type::DateTime),
            (LeftSymbol.Type = LeftSymbol.Type::DateTime) and IsNumeric(RightSymbol):
                ResultSymbol := ValidateDateTimeNumber(
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
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Guid),
            (LeftSymbol.Type = LeftSymbol.Type::Guid) and (RightSymbol.Type = RightSymbol.Type::Text),
            (LeftSymbol.Type = LeftSymbol.Type::Guid) and (RightSymbol.Type = RightSymbol.Type::Guid),
            (LeftSymbol.Type = LeftSymbol.Type::Char) and (RightSymbol.Type = RightSymbol.Type::Char),
            (LeftSymbol.Type = LeftSymbol.Type::Text) and (RightSymbol.Type = RightSymbol.Type::Char),
            (LeftSymbol.Type = LeftSymbol.Type::Char) and (RightSymbol.Type = RightSymbol.Type::Text),
            IsNumeric(LeftSymbol) and IsNumeric(RightSymbol),
            (LeftSymbol.Type = LeftSymbol.Type::Boolean) and (RightSymbol.Type = RightSymbol.Type::Boolean),
            (LeftSymbol.Type = LeftSymbol.Type::Date) and (RightSymbol.Type = RightSymbol.Type::Date),
            (LeftSymbol.Type = LeftSymbol.Type::Time) and (RightSymbol.Type = RightSymbol.Type::Time),
            (LeftSymbol.Type = LeftSymbol.Type::DateTime) and (RightSymbol.Type = RightSymbol.Type::DateTime):
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
    var
        DecimalResult: Boolean;
    begin
        case Operator of
            Operator::"+",
            Operator::"-",
            Operator::"*":
                DecimalResult := (LeftSymbol.Type = Enum::"Type FS"::Decimal)
                    or (RightSymbol.Type = Enum::"Type FS"::Decimal);
            Operator::"/":
                DecimalResult := true;
            Operator::"div",
            Operator::"mod":
                DecimalResult := RightSymbol.Type = Enum::"Type FS"::Decimal;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        if DecimalResult then
            exit(SymbolTable.DecimalSymbol());
        exit(SymbolTable.IntegerSymbol());
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

    local procedure ValidateDateTime
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        // TODO validate parameter types
        case Operator of
            Operator::"-":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.IntegerSymbol());
    end;

    local procedure ValidateDateNumber
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        // TODO validate parameter types
        case Operator of
            Operator::"+",
            Operator::"-":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.DateSymbol());
    end;

    local procedure ValidateTimeNumber
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        // TODO validate parameter types
        case Operator of
            Operator::"+",
            Operator::"-":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.TimeSymbol());
    end;

    local procedure ValidateDateTimeNumber
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS"
    ): Record "Symbol FS"
    begin
        // TODO validate parameter types
        case Operator of
            Operator::"+",
            Operator::"-":
                ;
            else
                Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
        end;

        exit(SymbolTable.DateTimeSymbol());
    end;

    local procedure ValidateChar
    (
        SymbolTable: Codeunit "Symbol Table FS";
        LeftSymbol: Record "Symbol FS";
        RightSymbol: Record "Symbol FS";
        Operator: Enum "Operator FS";
        LeftIsLiteral: Boolean;
        RightIsLiteral: Boolean
    ): Record "Symbol FS"
    begin
        if LeftIsLiteral and RightIsLiteral then begin
            case Operator of
                Operator::"+":
                    ;
                else
                    Error('Operator %1 is not supported for types %2 and %3.', Operator, LeftSymbol.Type, RightSymbol.Type);
            end;

            exit(SymbolTable.TextSymbol());
        end;

        exit(ValidateNumeric(
            SymbolTable,
            LeftSymbol,
            RightSymbol,
            Operator
        ));
    end;

    local procedure IsNumeric(Variant: Variant): Boolean
    begin
        exit(
            Variant.IsInteger()
            or Variant.IsDecimal()
            or Variant.IsChar()
        );
    end;

    local procedure IsNumeric(Symbol: Record "Symbol FS"): Boolean
    begin
        // FIXME instead check if coercible to number?
        exit(Symbol.Type in [
            Symbol.Type::Integer,
            Symbol.Type::Decimal,
            Symbol.Type::Char
        ]);
    end;
}