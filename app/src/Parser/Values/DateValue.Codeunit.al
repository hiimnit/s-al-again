codeunit 69106 "Date Value FS" implements "Value FS"
{
    var
        Value: Date;

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
        exit(Enum::"Type FS"::Date);
    end;

    procedure Copy(): Interface "Value FS"
    var
        DateValue: Codeunit "Date Value FS";
    begin
        DateValue.SetValue(Value);
        exit(DateValue);
    end;

    procedure GetProperty(Name: Text[120]): Interface "Value FS";
    begin
        Error('Date values do not support property access');
    end;

    procedure SetProperty(Name: Text[120]; NewValue: Interface "Value FS");
    begin
        Error('Date values do not support property access');
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