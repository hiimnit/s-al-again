codeunit 69110 "DateFormula Value FS" implements "Value FS"
{
    var
        Value: DateFormula;

    procedure GetValue(): Variant;
    begin
        exit(Value);
    end;

    procedure SetValue(NewValue: Variant);
    begin
        Value := NewValue;
    end;

    procedure GetType(): Enum "Type FS"
    begin
        exit(Enum::"Type FS"::DateFormula);
    end;

    procedure Copy(): Interface "Value FS"
    var
        DateFormulaValue: Codeunit "DateFormula Value FS";
    begin
        DateFormulaValue.SetValue(Value);
        exit(DateFormulaValue);
    end;

    procedure Mutate(NewValue: Interface "Value FS");
    begin
        Value := NewValue.GetValue();
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('DateFormula values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('DateFormula values do not support property access');
    end;

    procedure Format(): Text;
    begin
        exit(System.Format(Value));
    end;

    procedure Format(Length: Integer): Text;
    begin
        exit(System.Format(Value, Length));
    end;

    procedure Format(Length: Integer; FormatNumber: Integer): Text;
    begin
        exit(System.Format(Value, Length, FormatNumber));
    end;

    procedure Format(Length: Integer; FormatString: Text): Text;
    begin
        exit(System.Format(Value, Length, FormatString));
    end;

    procedure Evaluate(Input: Text; Throw: Boolean): Boolean
    begin
        if not Throw then
            exit(System.Evaluate(Value, Input));

        System.Evaluate(Value, Input);
        exit(true);
    end;

    procedure Evaluate(Input: Text; FormatNumber: Integer; Throw: Boolean): Boolean
    begin
        if not Throw then
            exit(System.Evaluate(Value, Input, FormatNumber));

        System.Evaluate(Value, Input, FormatNumber);
        exit(true);
    end;

    procedure At(Self: Interface "Value FS"; Index: Interface "Value FS"): Interface "Value FS"
    begin
        Error('DateFormula values do not support index access.');
    end;
}