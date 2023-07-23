codeunit 69113 "Record Field Value FS" implements "Value FS"
{
    var
        FieldRef: FieldRef;

    procedure Init
    (
        NewFieldRef: FieldRef
    )
    begin
        FieldRef := NewFieldRef;
    end;

    procedure GetValue(): Variant
    begin
        exit(FieldRef.Value());
    end;

    procedure SetValue(NewValue: Variant)
    begin
        FieldRef.Value(NewValue);
    end;

    procedure Copy(): Interface "Value FS"
    begin
        exit(ValueFromVariant(
            FieldRef.Value()
        ));
    end;

    procedure Mutate(NewValue: Interface "Value FS")
    begin
        FieldRef.Value(NewValue.GetValue());
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS"
    begin
        Error('Record Field values do not support property access');
    end;

    // TODO is using Copy in Format a good idea?
    procedure Format(): Text;
    begin
        exit(Copy().Format());
    end;

    procedure Format(Length: Integer): Text;
    begin
        exit(Copy().Format(Length));
    end;

    procedure Format(Length: Integer; FormatNumber: Integer): Text;
    begin
        exit(Copy().Format(Length, FormatNumber));
    end;

    procedure Format(Length: Integer; FormatString: Text): Text;
    begin
        exit(Copy().Format(Length, FormatString));
    end;

    procedure Evaluate(Input: Text; Throw: Boolean): Boolean
    var
        Value: Interface "Value FS";
    begin
        Value := Copy();

        if not Value.Evaluate(Input, Throw) then
            exit(false);

        Mutate(Value);

        exit(true);
    end;

    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean
    var
        Value: Interface "Value FS";
    begin
        Value := Copy();

        if not Value.Evaluate(Input, FormatNumber, Throw) then
            exit(false);

        Mutate(Value);

        exit(true);
    end;

    procedure At(Self: Interface "Value FS"; IndexValue: Interface "Value FS"): Interface "Value FS"
    begin
        // TODO this is a hack, used instead of reimplementing individual `Value.At`s
        exit(Copy().At(Self, IndexValue));
    end;

    local procedure ValueFromVariant(Variant: Variant): Interface "Value FS"
    var
        IntegerValue: Codeunit "Integer Value FS";
        DecimalValue: Codeunit "Decimal Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        TextValue: Codeunit "Text Value FS";
        CodeValue: Codeunit "Code Value FS";
        DateValue: Codeunit "Date Value FS";
        TimeValue: Codeunit "Time Value FS";
        DateTimeValue: Codeunit "DateTime Value FS";
        GuidValue: Codeunit "Guid Value FS";
        DateFormulaValue: Codeunit "DateFormula Value FS";
        CharValue: Codeunit "Char Value FS";
        OptionValue: Codeunit "Option Value FS";
    begin
        case true of
            Variant.IsInteger():
                begin
                    IntegerValue.SetValue(Variant);
                    exit(IntegerValue);
                end;
            Variant.IsDecimal():
                begin
                    DecimalValue.SetValue(Variant);
                    exit(DecimalValue);
                end;
            Variant.IsBoolean():
                begin
                    BooleanValue.SetValue(Variant);
                    exit(BooleanValue);
                end;
            Variant.IsText():
                begin
                    TextValue.SetValue(Variant);
                    exit(TextValue);
                end;
            Variant.IsCode():
                begin
                    CodeValue.SetValue(Variant);
                    exit(CodeValue);
                end;
            Variant.IsDate():
                begin
                    DateValue.SetValue(Variant);
                    exit(DateValue);
                end;
            Variant.IsTime():
                begin
                    TimeValue.SetValue(Variant);
                    exit(TimeValue);
                end;
            Variant.IsDateTime():
                begin
                    DateTimeValue.SetValue(Variant);
                    exit(DateTimeValue);
                end;
            Variant.IsGuid():
                begin
                    GuidValue.SetValue(Variant);
                    exit(GuidValue);
                end;
            Variant.IsDateFormula():
                begin
                    DateFormulaValue.SetValue(Variant);
                    exit(DateFormulaValue);
                end;
            Variant.IsChar():
                begin
                    CharValue.SetValue(Variant);
                    exit(CharValue);
                end;
            Variant.IsOption():
                begin
                    OptionValue.Init(
                        FieldRef.OptionMembers(),
                        FieldRef.OptionCaption()
                    );
                    OptionValue.SetValue(Variant);
                    exit(OptionValue);
                end;
            else
                Error('Initilization of type from value %1 is not supported.', Variant);
        end;
    end;
}