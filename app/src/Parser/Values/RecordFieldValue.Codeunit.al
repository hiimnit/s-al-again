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
        Error('unimplemented');
    end;

    procedure Copy(): Interface "Value FS"
    begin
        exit(ValueFromVariant(
            FieldRef.Value()
        ));
    end;

    procedure Mutate(NewValue: Interface "Value FS")
    begin
        Error('unimplemented');
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
        Char: Char;
    begin
        Error('unimplemented');

        if not Throw then begin
            if not System.Evaluate(Char, Input) then
                exit(false);

            SetValue(Char);
            exit(true);
        end;

        System.Evaluate(Char, Input);
        SetValue(Char);
        exit(true);
    end;

    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean
    var
        Char: Char;
    begin
        Error('unimplemented');

        if not Throw then begin
            if not System.Evaluate(Char, Input, FormatNumber) then
                exit(false);

            SetValue(Char);
            exit(true);
        end;

        System.Evaluate(Char, Input, FormatNumber);
        SetValue(Char);
        exit(true);
    end;

    procedure At(Self: Interface "Value FS"; IndexValue: Interface "Value FS"): Interface "Value FS"
    begin
        Error('unimplemented');
        // TODO call at on value?
        // >>>> how is `Currency.Code[1] := 'X'` going to work?
        // >>>> it should, but "Text Char Value FS" will have to be created here using this value 
    end;

    local procedure ValueFromVariant(Variant: Variant): Interface "Value FS"
    var
        NumericValue: Codeunit "Numeric Value FS";
        BooleanValue: Codeunit "Boolean Value FS";
        TextValue: Codeunit "Text Value FS";
        DateValue: Codeunit "Date Value FS";
        TimeValue: Codeunit "Time Value FS";
        DateTimeValue: Codeunit "DateTime Value FS";
        GuidValue: Codeunit "Guid Value FS";
        DateFormulaValue: Codeunit "DateFormula Value FS";
        CharValue: Codeunit "Char Value FS";
    begin
        case true of
            Variant.IsInteger(),
            Variant.IsDecimal():
                begin
                    NumericValue.SetValue(Variant);
                    exit(NumericValue);
                end;
            Variant.IsBoolean():
                begin
                    BooleanValue.SetValue(Variant);
                    exit(BooleanValue);
                end;
            Variant.IsCode(),
            Variant.IsText():
                begin
                    TextValue.SetValue(Variant);
                    exit(TextValue);
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
            else
                Error('Initilization of type from value %1 is not supported.', Variant);
        end;
    end;
}