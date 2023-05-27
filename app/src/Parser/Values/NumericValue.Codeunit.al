codeunit 69101 "Numeric Value FS" implements "Value FS"
{
    var
        Value: Decimal;

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
        exit(Enum::"Type FS"::Number);
    end;

    procedure Copy(): Interface "Value FS"
    var
        NumericValue: Codeunit "Numeric Value FS";
    begin
        NumericValue.SetValue(Value);
        exit(NumericValue);
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Numeric values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Numeric values do not support property access');
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
}